# Ownership vs Selectors

While working on my project [kubedump](https://github.com/joshmeranda/kubedump) I was working a lot with filtering based
on ownership and labels. I ran into a big issue when thinking about how to handle resources related to resources that
match filters. For example, how do we keep the child pods of a replicaset?

## Ownership Checking

As you can see in the [ObjectMeta Api Spec](https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/object-meta/#System),
all resources will store a list of `OwnerReferences` which will only be populated if the resource involved in an
ownership relationship. So the first downside of leveraging ownership is that not all resource relationships would be
acknowledged (ex `Pods` and `Services`).

Since this is only one level deep (replicaset -> pod) and `Pod`s keep a reference to their owners (via
`ObjectMeta.OwnerReferences`), this is actually super easy. But when this is pushed out another level by matching the
pod by filtering on a `Deployment`, this gets a lot less friendly.

We are still able to find a reference to the `Pod`'s `ReplicaSet` owner, but what then? We only have access to its name
and namespace, so we can't just look for that `ReplicaSet`'s `Deployment` owner, but we can fetch that `ReplicaSet` and
then look through its owner's to then find that final `Deployment` grandaddy. This seems to work fine, but I can see it
being a potential problem later since isn't any guarantee that resources will have only one owner, especially when it
comes to `CRD`s. Too many owners and we'll have to start traversing entire ownership trees with a network call for each
member of that family.

## Label Selector Checking

But is it any easier to do this with selectors? We won't have to deal with the **ENTIRE** resource hierarchy since we'll
only be checking if a resource matches any stored label selectors. Where ownership is a bottom-top relationship, so we
can effortlessly know what owns a resource, label selectors are top-bottom meaning that we have to check with the parent
to see if the child is theirs. This means we'll have to show each parent each child and ask if it's theirs. Even worse
each child could have many parents, so we can't stop checking until each parent has been asked.

One issue potential issue with this is race conditions. What happens when a `Service` is created and its selectors
registered and then a deployment is created with those selectors? If the dump is stopped before anything can happen
with that deployment, then no information will be recorded for it. While this is not very likely, it is still certainly
possible, and users of kubedump should at least be aware of it.

On the other hand, since many resources which have ownership over another resource will also have a label selector for
that child, we should be able to handle any ownership relationships by relying entirely on label selectors.

## Verdict

Since resources with ownership will also create a label selector (ex `controller-uid=<owner-uid>`), we can lean entirely
on the labels selector mechanism when watching for related resources.
