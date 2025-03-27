## Definition of the Append Function
 
In F*, a function to append two lists can be defined recursively. The append function takes two lists as input and returns a new list that consists of the elements of the first list followed by the elements of the second list. This can be expressed as follows:
 
```fsharp
let rec append l1 l2 = match l1 with
| [] -> l2
| x::xs -> x :: append xs l2
```
 
This definition ensures that all elements from both lists are included in the resulting list without any loss or duplication [Data: Reports (1, 12, 171, 25, 26)].
 
## Proof of Non-Loss and Non-Duplication of Elements
 
To prove that elements are not lost or duplicated during the append operation, we can utilize induction on the structure of the first list.
 
### Base Case
 
When the first list is empty (`l1 = []`), the result of the append operation is simply the second list (`l2`). In this case, all elements of `l2` are preserved, and there are no elements from `l1` to duplicate. Thus, the property holds.
 
### Inductive Step
 
Assume that the property holds for a list of length `n`, meaning that appending a list with `n` elements to another list preserves all elements without loss or duplication. Now consider a list of length `n+1`, which can be expressed as `x::xs` where `x` is the head and `xs` is the tail of the list.
 
When we append `x::xs` to `l2`, the operation proceeds as follows:
 
1. The head `x` is added to the result.
2. The function then recursively appends the tail `xs` to `l2`.
 
By the inductive hypothesis, we know that appending `xs` to `l2` preserves all elements from `xs` and `l2`. Since `x` is a new element being added to the result, it does not duplicate any elements from `l2`. Therefore, the resulting list contains all elements from both `l1` and `l2` exactly once.
 
### Conclusion
 
By induction, we have shown that the append function maintains the integrity of both lists, ensuring that no elements are lost or duplicated during the append operation. This proof can be further supported by formal verification techniques that demonstrate the correctness of the append function in F* [Data: Reports (139, 186)].
 
In summary, the append function is defined recursively, and through induction, we have established that it preserves the uniqueness and order of elements from both input lists.