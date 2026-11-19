# Project 3: Functional Programming with Common Lisp

**Team name:** Computa

**Team members:**
- Diego Salas
- Gage Gunn
- Sam Holton

## Running the program

You need a Common Lisp implementation. We used SBCL (Steel Bank Common Lisp).

To run all the tests, go into the `Project3` folder and run:

```
sbcl --script tests.lisp
```

This loads `Computa_project3.lisp` and prints every test with the function name,
the input, the expected result, the actual result, and PASS or FAIL. At the end
it prints how many tests passed.

To try the functions yourself, start `sbcl` from the `Project3` folder and load the file:

```lisp
(load "Computa_project3.lisp")
(merge-sort '(2 1 5 0) #'>)          ; => (5 2 1 0)
(boolean-simplify '(and (or a nil) t)) ; => A
```

## Demo

For the presentation we have a menu in `demo.lisp` at the top of the repo
(outside this folder). Run it from the repo root:

```
sbcl --script demo.lisp
```

It walks through each section with the handout examples (or your own input),
ranks the students by average with `merge-sort`, shows the recursion step by
step using TRACE, and can run the whole test suite. It only calls the functions
in `Computa_project3.lisp`.

If SBCL is blocked on Windows (Smart App Control stops unsigned programs), the
same thing works through Docker from the repo root:

```
docker run -it --rm -v "${PWD}:/app" -w /app clfoundation/sbcl sbcl --script demo.lisp
```

## Files

```
Project3/
|-- Computa_project3.lisp   all the required functions and their helpers
|-- tests.lisp              our test cases and a small test runner
|-- README.md               this file
```

## Program structure

`Computa_project3.lisp` is split into the same sections as the assignment.
Later sections build on earlier ones instead of repeating code:

- The set functions are used all over. `set-member` drives the other set
  operations, `set-diff` is used by `list-remove-duplicates`, and
  `set-intersection` is used by `common-courses`.
- `list-remove-duplicates` is used by `common-courses` so the result never
  has duplicates, even if a course was listed twice.
- `set-join` (our replacement for APPEND) is used by `set-union`,
  `set-symmetric-diff` and `list-flatten`.
- `list-reverse` is used by `list-palindrome`.
- `list-flatten` is used by `boolean-simplify` to tell symbols apart from
  expressions (see below).
- `get-student-courses` is used by `common-courses`.

Everything is done with recursion. There are no loops and nothing is changed in
place. Every function builds a new list with CONS instead.

`tests.lisp` has a `test-case` macro that runs one call and prints the results,
and a `test-unchanged` macro that checks the inputs are the same after the call.

## Functions

### Section 3: Set Operations
| Function | What it does |
|---|---|
| `set-member` | T if the item is in the set, NIL otherwise |
| `set-union` | Everything in set-1, then anything from set-2 that isn't already there |
| `set-intersection` | Items in both sets, in set-1's order |
| `set-diff` | Items in set-1 that aren't in set-2 |
| `set-symmetric-diff` | Items in exactly one of the two sets |
| `set-join` (helper) | Sticks two lists together (we can't use APPEND) |

### Section 4: Boolean Logic
| Function | What it does |
|---|---|
| `boolean-xor` | T when exactly one input is true |
| `boolean-implies` | NIL only when A is true and B is false |
| `boolean-iff` | T when both inputs have the same value |
| `boolean-eval` | Evaluates nested NOT, AND, OR, XOR, IMPLIES and IFF expressions |
| `boolean-simplify` | Simplifies an expression using the rules from the assignment |

`boolean-simplify` works bottom up. It simplifies the inner parts first and then
applies the rules to the outer expression, so it keeps going until nothing else
can be simplified. Helpers: `boolean-simplify-not`, `boolean-simplify-and`,
`boolean-simplify-or` and `boolean-atom-p`.

### Section 5: Recursive List Processing
| Function | What it does |
|---|---|
| `list-reverse` | Reverses a list using an accumulator |
| `list-flatten` | Turns a nested list into one flat list (empty sublists are dropped) |
| `list-remove-duplicates` | Keeps the first copy of each item |
| `list-palindrome` | T if the list is the same backwards |

### Section 6: Merge Sort
| Function | What it does |
|---|---|
| `merge-sort` | Sorts a list with any compare function, like `#'<` or `#'>` |
| `merge-sort-split` (helper) | Deals the list into two halves, odd positions and even positions |
| `merge-sort-merge` (helper) | Merges two sorted lists into one |

We split by dealing elements out one at a time instead of cutting the list at the
middle, because cutting at the middle needs FLOOR, which isn't on the allowed list.

### Section 7: Student Course Analyzer
| Function | What it does |
|---|---|
| `get-student-courses` | The course ids for one student, or NIL if they don't exist |
| `student-average` | Sum of grades divided by number of courses (exact, like 253/3) |
| `common-courses` | Courses two students share, using `set-intersection` and `list-remove-duplicates` |
| `find-student`, `course-ids`, `grade-sum` (helpers) | Find a record, pull out course ids, add up grades |

## Known limitations

- The set functions expect sets with no duplicates, like the assignment says.
  If you pass in a list with duplicates, they can show up in the result.
- `boolean-eval` only works with T and NIL. Variables like A and B can't be evaluated.
- `boolean-simplify` only uses the rules listed in the assignment. For example,
  `(and a (not a))` is left alone even though it is always NIL.
- `boolean-simplify` calls `boolean-atom-p`, which flattens the expression every
  time, so it gets slower on very big expressions. We did it this way because the
  spec only allows ATOM inside `list-flatten`.
- `merge-sort` is not stable. Items that compare as equal might not stay in
  their original order. They are never lost, though.
- `student-average` will give a divide-by-zero error for a student who doesn't
  exist or has no courses. The assignment says that case won't be asked.
- Nothing is tail recursive, so very long lists (tens of thousands of items)
  could run out of stack.
- Loading the file in the REPL prints a couple of "undefined function" style
  warnings. That's because some functions call ones defined further down the
  file. Everything still works once the whole file is loaded.
