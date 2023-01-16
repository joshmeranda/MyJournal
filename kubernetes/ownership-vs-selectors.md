# Ownership vs Selectors

While working on my k8s [kubedump](https://github.com/joshmeranda/kubedump) I was working a lot with filtering based on
ownership and labels. I ran into a big issue when thinking about how to handle the child / related resources of
resources that match filters. For example, how do we keep the child pods of a replicaset?

## Ownership Checking
Since this is only one level deep (replicaset -> pod) and `Pod`s keep a reference to their owners (via
`ObjectMeta.OwnerReferences`), this is actually super easy. But when this is pushed out another level by matching the
pod by filtering on a `Deployment`, this gets a lot less friendly. We are still able to find a reference to the `Pod`'s
`ReplicaSet` owner, but what then? We only have access to its name and namespace, so we can't just look for that
`ReplicaSet`'s `Deployment` owner, but we can fetch that `ReplicaSet` and then look through its owner's to then find
that final `Deployment` grandaddy. This seems to work fine, but I can see it being a potential problem later since
isn't any guarantee that resources will have only one owner, especially when it comes to `CRD`s. Too many owners and
we'll have to start traversing entire ownership trees with a network call at each level.

## Label Selector Checking

But is it any easier to do this with selectors? We won't have to deal with the **ENTIRE** resource hierarchy since we'll
only be checking if a resource matches any stored label selectors. Where ownership is a bottom-top relationship, so we
can effortlessly know what owns a resource, label selectors are top-bottom meaning that we have to check with the parent
to see if the child is theirs. This means we'll have to show each parent each child and ask if it's theirs. Even worse
each child could have many parents, so we can't stop checking until each parent has been asked.

One issue potential issue with this is race conditions. What happens when a `Service` is created and its selectors
registered and then a deployment is created with those selectors? If the dump isd stopped before anything can happen
with that deployment, then no information will be recorded for it. While this is not very likely, it is still certainly
possible, and users of kubedump should at least be aware of it.

Unfortunately, since k8s relies so much on label selectors we cannot ignore the selectors.

## Verdict

One of the main goals of kubedump is to capture the real state of a k8s cluster, so we cannot just ignore them.
Ownership is fast to process and could still provide some insight, so handling ownership is still useful for situations
like `Job` pods which do not have any true label selectors.

In the end, if I had to choose one over the other, I'd do labels. But for the best user experience handling both is 
ideal.
