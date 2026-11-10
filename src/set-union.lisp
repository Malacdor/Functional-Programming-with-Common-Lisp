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
