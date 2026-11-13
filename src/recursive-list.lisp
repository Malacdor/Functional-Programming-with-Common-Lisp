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
