;;;; Section 3: Set Operations

(defun set-join (front back)
  (if (not front)
      back
      (cons (first front) (set-join (cdr front) back))))

(defun set-member (set item)
  (cond ((not set) nil)
        ((equal (first set) item) t)
        (t (set-member (cdr set) item))))

(defun set-union (set-1 set-2)
  (set-join set-1 (set-diff set-2 set-1)))

(defun set-intersection (set-1 set-2)
  (cond ((not set-1) nil)
        ((set-member set-2 (first set-1))
         (cons (first set-1) (set-intersection (cdr set-1) set-2)))
        (t (set-intersection (cdr set-1) set-2))))

(defun set-diff (set-1 set-2)
  (cond ((not set-1) nil)
        ((set-member set-2 (first set-1)) (set-diff (cdr set-1) set-2))
        (t (cons (first set-1) (set-diff (cdr set-1) set-2)))))

(defun set-symmetric-diff (set-1 set-2)
  (set-join (set-diff set-1 set-2) (set-diff set-2 set-1)))


;;;; Section 4: Boolean Logic

(defun boolean-xor (a b)
  (and (or a b) (not (and a b))))

(defun boolean-implies (a b)
  (if a (and b t) t))

(defun boolean-iff (a b)
  (not (boolean-xor a b)))

(defun boolean-eval (exp)
  (cond ((equal exp t) t)
        ((equal exp nil) nil)
        ((equal (first exp) 'not)
         (not (boolean-eval (second exp))))
        ((equal (first exp) 'and)
         (and (boolean-eval (second exp)) (boolean-eval (third exp))))
        ((equal (first exp) 'or)
         (or (boolean-eval (second exp)) (boolean-eval (third exp))))
        ((equal (first exp) 'xor)
         (boolean-xor (boolean-eval (second exp)) (boolean-eval (third exp))))
        ((equal (first exp) 'implies)
         (boolean-implies (boolean-eval (second exp)) (boolean-eval (third exp))))
        ((equal (first exp) 'iff)
         (boolean-iff (boolean-eval (second exp)) (boolean-eval (third exp))))))

(defun boolean-atom-p (exp)
  (atom exp))

(defun boolean-simplify-not (x)
  (if (and (not (boolean-atom-p x)) (equal (first x) 'not))
      (second x)
      (list 'not x)))

(defun boolean-simplify-and (x y)
  (cond ((equal x t) y)
        ((equal y t) x)
        ((equal x nil) nil)
        ((equal y nil) nil)
        ((equal x y) x)
        (t (list 'and x y))))

(defun boolean-simplify-or (x y)
  (cond ((equal x nil) y)
        ((equal y nil) x)
        ((equal x t) t)
        ((equal y t) t)
        ((equal x y) x)
        (t (list 'or x y))))

(defun boolean-simplify (exp)
  (cond ((boolean-atom-p exp) exp)
        ((equal (first exp) 'not)
         (boolean-simplify-not (boolean-simplify (second exp))))
        ((equal (first exp) 'and)
         (boolean-simplify-and (boolean-simplify (second exp))
                               (boolean-simplify (third exp))))
        ((equal (first exp) 'or)
         (boolean-simplify-or (boolean-simplify (second exp))
                              (boolean-simplify (third exp))))
        (t (list (first exp)
                 (boolean-simplify (second exp))
                 (boolean-simplify (third exp))))))




;;;; Section 5: Recursive List Processing


(defun list-reverse (lst)
  (labels ((walk (rest reversed)
             (if (not rest)
                 reversed
                 (walk (cdr rest) (cons (first rest) reversed)))))
    (walk lst nil)))

(defun list-flatten (lst)
  (cond ((not lst) nil)
        ((not (first lst)) (list-flatten (cdr lst)))
        ((atom (first lst))
         (cons (first lst) (list-flatten (cdr lst))))
        (t (set-join (list-flatten (first lst))
                     (list-flatten (cdr lst))))))

(defun list-remove-duplicates (lst)
  (if (not lst)
      nil
      (cons (first lst)
            (list-remove-duplicates (set-diff (cdr lst) (list (first lst)))))))

(defun list-palindrome (lst)
  (equal lst (list-reverse lst)))
;;;; Section 6: Merge Sort
;;;; Functions: merge-sort, plus helper functions for splitting and merging
;;;; Sections 7 and 8: Student Course Analyzer and Application Integration
;;;; Functions: get-student-courses, student-average, common-courses
