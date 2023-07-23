(in-package :graphene-test)

(def-suite graphene-point :in graphene-suite)
(in-suite graphene-point)

(export 'graphene-point)

;;; --- Types and Values -------------------------------------------------------

;;;     graphene_point_t

;;; --- Macros -----------------------------------------------------------------

;;;     with-graphene-point

(test with-graphene-point.1
  (graphene:with-graphene-point (p)
    (is (= 0.0 (graphene:point-x p)))
    (is (= 0.0 (graphene:point-y p)))))

(test with-graphene-point.2
  (graphene:with-graphene-point (p 1 2)
    (is (= 1.0 (graphene:point-x p)))
    (is (= 2.0 (graphene:point-y p)))))

(test with-graphene-point.3
  (graphene:with-graphene-points ((p1 3 4) (p p1))
    (is (= 3.0 (graphene:point-x p)))
    (is (= 4.0 (graphene:point-y p)))))

(test with-graphene-point.4
  (graphene:with-graphene-points ((p1 5 6) (p (p1 graphene:point-t)))
    (is (= 5.0 (graphene:point-x p)))
    (is (= 6.0 (graphene:point-y p)))))

(test with-graphene-point.5
  (graphene:with-graphene-vec2 (v 1.5 2.5)
    (graphene:with-graphene-point (p (v graphene:vec2-t))
      (is (= 1.5 (graphene:point-x p)))
      (is (= 2.5 (graphene:point-y p))))))

(test with-graphene-point.6
  (let ((a 3.5) (b 4.5))
    (graphene:with-graphene-point (p a b)
      (is (= 3.5 (graphene:point-x p)))
      (is (= 4.5 (graphene:point-y p))))))

;;;     with-graphene-points

(test with-graphene-points.1
  (graphene:with-graphene-points ((p1) (p2) (p3))
    (is (graphene:point-equal p1 (graphene:point-zero)))
    (is (graphene:point-equal p2 (graphene:point-zero)))
    (is (graphene:point-equal p3 (graphene:point-zero)))))

(test with-graphene-points.2
  (graphene:with-graphene-points (p1 p2 p3)
    (is (graphene:point-equal p1 (graphene:point-zero)))
    (is (graphene:point-equal p2 (graphene:point-zero)))
    (is (graphene:point-equal p3 (graphene:point-zero)))))

(test with-graphene-points.3
  (graphene:with-graphene-points (p1 (p2 1 2) (p3 p2) (p4 (p3 graphene:point-t)))
    (is (graphene:point-equal p1 (graphene:point-zero)))
    (is (= 1.0 (graphene:point-x p2)))
    (is (= 2.0 (graphene:point-y p2)))
    (is (graphene:point-equal p3 p2))
    (is (graphene:point-equal p4 p3))))

(test with-graphene-points.4
  (graphene:with-graphene-vec2 (v 1.5 2.5)
    (graphene:with-graphene-points ((p1 (v graphene:vec2-t)) p2 (p3 p1))
      (is (= 1.5 (graphene:point-x p1)))
      (is (= 2.5 (graphene:point-y p1)))
      (is (graphene:point-equal p2 (graphene:point-zero)))
      (is (graphene:point-equal p3 p1)))))

;;; --- Functions --------------------------------------------------------------

;;;     point-x
;;;     point-y

(test point-x/y
  (graphene:with-graphene-point (p)
    (is (= 0.0 (graphene:point-x p)))
    (is (= 0.0 (graphene:point-y p)))
    (is (= 1.0 (setf (graphene:point-x p) 1.0)))
    (is (= 2.0 (setf (graphene:point-y p) 2.0)))
    (is (= 1.0 (graphene:point-x p)))
    (is (= 2.0 (graphene:point-y p)))))

;;;     graphene_point_alloc
;;;     graphene_point_free

(test point-alloc/free
  (let ((point nil))
    (is (cffi:pointerp (setf point (graphene:point-alloc))))
    (is (= 0.0 (graphene:point-x point)))
    (is (= 0.0 (graphene:point-y point)))
    (is-false (graphene:point-free point))))

;;;     graphene_point_zero

(test point-zero.1
  (let ((p (graphene:point-zero)))
    (is (cffi:pointerp p))
    (is (= 0.0 (graphene:point-x p)))
    (is (= 0.0 (graphene:point-y p)))))

(test point-zero.2
  (graphene:with-graphene-points (p1 (p2 1 2))
    (is (graphene:point-equal p1 (graphene:point-zero)))
    (is (not (graphene:point-equal p2 (graphene:point-zero))))))

;;;     graphene_point_init

(test point-init.1
  (graphene:with-graphene-point (p)
    (is (graphene:point-equal p (graphene:point-zero)))
    (is (cffi:pointer-eq p (graphene:point-init p 1.0 2.0)))
    (is (= 1.0 (graphene:point-x p)))
    (is (= 2.0 (graphene:point-y p)))
    (is (cffi:pointer-eq p (graphene:point-init p 1 1/2)))
    (is (= 1.0 (graphene:point-x p)))
    (is (= 0.5 (graphene:point-y p)))
    (is (cffi:pointer-eq p (graphene:point-init p 2.5d0 3.5d0)))
    (is (= 2.5 (graphene:point-x p)))
    (is (= 3.5 (graphene:point-y p)))))

(test point-init.2
  (graphene:with-graphene-point (p 1.0 2.0)
    (is (= 1.0 (graphene:point-x p)))
    (is (= 2.0 (graphene:point-y p)))))

(test point-init.3
  (graphene:with-graphene-points ((p1 1.0 2.0) p2)
    (is (= 1.0 (graphene:point-x p1)))
    (is (= 2.0 (graphene:point-y p1)))
    (is (= 0.0 (graphene:point-x p2)))
    (is (= 0.0 (graphene:point-y p2)))))

;;;     graphene_point_init_from_point

(test point-init-from-point
  (graphene:with-graphene-points ((p1 1.0 2.0) p2)
    (is (cffi:pointer-eq p2 (graphene:point-init-from-point p2 p1)))
    (is (= 1.0 (graphene:point-x p2)))
    (is (= 2.0 (graphene:point-y p2)))))

;;;     graphene_point_init_from_vec2

(test point-init-from-vec2
  (graphene:with-graphene-vec2 (vector 1.5 2.5)
    (graphene:with-graphene-point (p)
      (is (cffi:pointer-eq p (graphene:point-init-from-vec2 p vector)))
      (is (= (graphene:vec2-x vector) (graphene:point-x p)))
      (is (= (graphene:vec2-y vector) (graphene:point-y p))))))

;;;     graphene_point_to_vec2

(test point-to-vec2
  (graphene:with-graphene-point (p 2.5 3.5)
    (graphene:with-graphene-vec2 (v)
      (is (cffi:pointer-eq v (graphene:point-to-vec2 p v)))
      (is (= 2.5 (graphene:vec2-x v)))
      (is (= 3.5 (graphene:vec2-y v))))))

;;;     graphene_point_equal

(test point-equal
  (graphene:with-graphene-points ((p1 1.0 2.0) (p2 1.0 2.0) (p3 0 0))
    (is (graphene:point-equal p1 p2))
    (is (not (graphene:point-equal p1 p3)))
    (is (not (graphene:point-equal p2 p3)))))

;;;     graphene_point_near

(test point-near
  (graphene:with-graphene-points ((p1 0.000 0.000) (p2 0.001 0.000) (p3 0.000 0.001))
    (is (graphene:point-near p1 p2 0.01))
    (is (graphene:point-near p1 p3 0.01))
    (is (not (graphene:point-near p1 p2 0.001)))
    (is (not (graphene:point-near p1 p3 0.001)))))

;;;     graphene_point_distance

(test point-distance
  (graphene:with-graphene-points ((p1 0.0 0.0) (p2 1.0 0.0) (p3 0.0 1.0))
    (is (equal '(1.0 1.0 0.0)
               (multiple-value-list (graphene:point-distance p1 p2))))
    (is (equal '(1.0 0.0 1.0)
               (multiple-value-list (graphene:point-distance p1 p3))))
    (is (equal '(1.4142135 1.0 1.0)
               (multiple-value-list (graphene:point-distance p2 p3))))))

;;;     graphene_point_interpolate

(test point-interpolate
  (graphene:with-graphene-points ((p1 0.0 0.0) (p2 1.0 0.0) (p3 0.0 1.0)
                         result)
    (is (cffi:pointer-eq result (graphene:point-interpolate p1 p2 0.1 result)))
    (is (= 0.1 (graphene:point-x result)))
    (is (= 0.0 (graphene:point-y result)))
    (is (cffi:pointer-eq result (graphene:point-interpolate p1 p3 0.1 result)))
    (is (= 0.0 (graphene:point-x result)))
    (is (= 0.1 (graphene:point-y result)))))

;;; 2022-10-1
