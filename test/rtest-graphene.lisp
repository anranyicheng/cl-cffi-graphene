(defpackage :graphene-test
  (:use :graphene :fiveam :cffi :common-lisp)
  (:export #:run!
           #:graphene-suite
           #:graphene-box
           #:graphene-euler
           #:graphene-frustum
           #:graphene-matrix
           #:graphene-plane
           #:graphene-point
           #:graphene-point3d
           #:graphene-quad
           #:graphene-quaternion
           #:graphene-ray
           #:graphene-rectangle
           #:graphene-size
           #:graphene-sphere
           #:graphene-triangle
           #:graphene-vector))

(in-package :graphene-test)

;; See https://www.embeddeduse.com/2019/08/26/qt-compare-two-floats/
(let ((eps-factor 1.0d-2))
  (defun approx-equal (x y)
    (or (< (abs (- x y)) eps-factor)
        (< (abs (- x y)) (* eps-factor (max (abs x) (abs y)))))))

(def-suite graphene-suite)
(in-suite graphene-suite)

;;; 2022-10-2
