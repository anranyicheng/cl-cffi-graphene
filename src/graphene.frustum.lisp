;;; ----------------------------------------------------------------------------
;;; graphene.frustum.lisp
;;;
;;; The documentation of this file is taken from the GRAPHENE Reference Manual
;;; and modified to document the Lisp binding to the Graphene library.
;;; See <https://ebassi.github.io/graphene/docs/>.
;;; The API documentation of the Lisp binding is available from
;;; <http://www.crategus.com/books/cl-cffi-graphene/>.
;;;
;;; Copyright (C) 2022 Dieter Kaiser
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU Lesser General Public License for Lisp
;;; as published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version and with a preamble to
;;; the GNU Lesser General Public License that clarifies the terms for use
;;; with Lisp programs and is referred as the LLGPL.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this program and the preamble to the Gnu Lesser
;;; General Public License.  If not, see <http://www.gnu.org/licenses/>
;;; and <http://opensource.franz.com/preamble.html>.
;;; ----------------------------------------------------------------------------
;;;
;;; Frustum
;;;
;;;     A 3D field of view
;;;
;;; Types and Values
;;;
;;;     graphene_frustum_t
;;;
;;; Functions
;;;
;;;     graphene_frustum_alloc
;;;     graphene_frustum_free
;;;     graphene_frustum_init
;;;     graphene_frustum_init_from_frustum
;;;     graphene_frustum_init_from_matrix
;;;     graphene_frustum_get_planes
;;;     graphene_frustum_contains_point
;;;     graphene_frustum_intersects_sphere
;;;     graphene_frustum_intersects_box
;;;     graphene_frustum_equal
;;; ----------------------------------------------------------------------------

(in-package :graphene)

(defmacro with-graphene-frustum ((var &rest args) &body body)
  (cond
;        ((not args)
;         ;; We have no arguments, the default is initialization with zeros.
;         `(let ((,var (frustum-alloc)))
;            (frustum-init-from-matrix ,var (matrix-zero))
;            (unwind-protect
;              (progn ,@body)
;              (box-free ,var))))

        ((and (first args) (not (second args)))
         ;; One argument
         (format t "one argument ~a~%" args)
         (destructuring-bind (arg &optional type)
             (if (listp (first args)) (first args) (list (first args)))
           (cond ((or (not type)
                      (eq type 'frustum-t))
                  ;; One argument with no type or of type frustum-t
                  `(let ((,var (frustum-alloc)))
                     (frustum-init-from-frustum ,var ,arg)
                     (unwind-protect
                       (progn ,@body)
                       (frustum-free ,var))))

                 ((eq type 'marrix-t)
                  ;; One argument with type matrix-t
                  `(let ((,var (frustum-alloc)))
                     (frustum-init-from-matrix ,var ,arg)
                     (unwind-protect
                       (progn ,@body)
                       (frustum-free ,var))))

                 (t
                  (error "Type error in WITH-GRAPHENE-FRUSTUM")))))

        ((not (seventh args))
         ;; Six arguments of type plane-t
         (format t "six argument ~a~%" args)
         `(let ((,var (frustum-alloc)))
            (frustum-init ,var ,@args)
            (unwind-protect
              (progn ,@body)
              (frustum-free ,var))))
        (t
         (error "Syntax error in WITH-GRAPHENE-FRUSTUM"))))

(export 'with-graphene-frustum)

(defmacro with-graphene-frustums (vars &body body)
  (if vars
      (let ((var (if (listp (first vars)) (first vars) (list (first vars)))))
        `(with-graphene-frustum ,var
           (with-graphene-frustums ,(rest vars)
             ,@body)))
      `(progn ,@body)))

(export 'with-graphene-frustums)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_t
;;; ----------------------------------------------------------------------------

(defcstruct frustum-t)

#+liber-documentation
(setf (liber:alias-for-symbol 'frustum-t)
      "CStruct"
      (liber:symbol-documentation 'frustum-t)
 "@version{#2022-9-25}
  @begin{short}
    A @sym{frustum-t} structure represents a volume of space delimited by
    planes.
  @end{short}
  It is usually employed to represent the field of view of a camera, and can be
  used to determine whether an object falls within that view, to efficiently
  remove invisible objects from the render process.")

(export 'frustum-t)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_alloc ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_alloc" frustum-alloc)
    (:pointer (:struct frustum-t))
 #+liber-documentation
 "@version{#2022-9-25}
  @return{The newly allocated @symbol{frustum-t} instance. Use the
    @fun{frustum-free} function to free the resources allocated by this
    function.}
  @begin{short}
    Allocates a new @symbol{frustum-t} instance.
  @end{short}
  The contents of the returned structure are undefined.
  @see-symbol{frustum-t}
  @see-function{frustum-free}")

(export 'frustum-alloc)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_free ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_free" frustum-free) :void
 #+liber-documentation
 "@version{#2022-9-25}
  @argument[frustum]{a @symbol{frustum-t} instance}
  @begin{short}
    Frees the resources allocated by the @fun{frustum-alloc} function.
  @end{short}
  @see-symbol{frustum-t}
  @see-function{frustum-alloc}"
  (frustum (:pointer (:struct frustum-t))))

(export 'frustum-free)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_init ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_init" frustum-init)
    (:pointer (:struct frustum-t))
 #+liber-documentation
 "@version{#2022-9-29}
  @argument[frustum]{a @symbol{frustum-t} instance}
  @argument[p0]{a @symbol{pane-t} instance with a clipping plane}
  @argument[p1]{a @symbol{pane-t} instance with a clipping plane}
  @argument[p2]{a @symbol{pane-t} instance with a clipping plane}
  @argument[p3]{a @symbol{pane-t} instance with a clipping plane}
  @argument[p4]{a @symbol{pane-t} instance with a clipping plane}
  @argument[p5]{a @symbol{pane-t} instance with a clipping plane}
  @return{The initialized @symbol{frustum-t} instance.}
  @begin{short}
    Initializes the given @symbol{frustum-t} instance using the provided
    clipping planes.
  @end{short}
  @see-symbol{frustum-t}
  @see-symbol{plane-t}"
  (frustum (:pointer (:struct frustum-t)))
  (p0 (:pointer (:struct plane-t)))
  (p1 (:pointer (:struct plane-t)))
  (p2 (:pointer (:struct plane-t)))
  (p3 (:pointer (:struct plane-t)))
  (p4 (:pointer (:struct plane-t)))
  (p5 (:pointer (:struct plane-t))))

(export 'frustum-init)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_init_from_frustum ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_init_from_frustum" frustum-init-from-frustum)
    (:pointer (:struct frustum-t))
 #+liber-documentation
 "@version{#2022-9-29}
  @argument[frustum]{a @symbol{frustum-t} instance to initialize}
  @argument[source]{a @symbol{frustum-t} instance}
  @return{The initialized @symbol{frustum-t} instance.}
  @begin{short}
    Initializes the given @symbol{frustum-t} instance using the clipping planes
    of another @symbol{frustum-t} instance.
  @end{short}
  @see-symbol{frustum-t}"
  (frustum (:pointer (:struct frustum-t)))
  (source (:pointer (:struct frustum-t))))

(export 'frustum-init-from-frustum)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_init_from_matrix ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_init_from_matrix" frustum-init-from-matrix)
    (:pointer (:struct frustum-t))
 #+liber-documentation
 "@version{#2022-9-29}
  @argument[frustum]{a @symbol{frustum-t} instance to initialize}
  @argument[matrix]{a @symbol{matrix-t} instance}
  @return{The initialized @symbol{frustum-t} instance.}
  @begin{short}
    Initializes the given @symbol{frustum-t} instance using given matrix.
  @end{short}
  @see-symbol{frustum-t}
  @see-symbol{matrix-t}"
  (frustum (:pointer (:struct frustum-t)))
  (matrix (:pointer (:struct matrix-t))))

(export 'frustum-init-from-matrix)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_get_planes ()
;;; ----------------------------------------------------------------------------

;; FIXME: The implementation does not work.

(defcfun ("graphene_frustum_get_planes" %frustum-planes) :void
  (frustum (:pointer (:struct frustum-t)))
  (values-ar :pointer))

(defun frustum-planes (frustum planes)
 #+liber-documentation
 "@version{#2022-9-29}
  @argument[frustum]{a @symbol{frustum-t} instance to initialize}
  @argument[planes]{a list with the @symbol{plane-t} instances}
  @return{The list of @symbol{plane-t} instances.}
  @begin{short}
    Retrieves the planes that define the given @symbol{frustum-t} instance.
  @end{short}
  @see-symbol{frustum-t}
  @see-symbol{plane-t}"
  (format t "~& in FRUSTUM-PLANES with ~a~%" planes)
  (with-graphene-vec3 (result)
  (with-foreign-object (planes-ar :pointer 6)
    (loop for i from 0 below 6
          for plane in planes
          do (format t " plane ~a : ~a ~a~%"
                       i
                       (vec3-to-float (plane-normal plane result))
                       (plane-constant plane))
             (setf (mem-aref planes-ar :pointer i) plane)
    )
    (%frustum-planes frustum planes-ar)
    planes)))

(export 'frustum-planes)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_contains_point ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_contains_point" frustum-contains-point) :bool
 #+liber-documentation
 "@version{#2022-9-29}
  @argument[frustum]{a @symbol{frustum-t} instance to initialize}
  @argument[point]{a @symbol{point3d-t} instance}
  @return{@em{True} if the point is inside the frustum.}
  @begin{short}
    Checks whether a point is inside the volume defined by the given frustum.
  @end{short}
  @see-symbol{frustum-t}
  @see-symbol{point3d-t}"
  (frustum (:pointer (:struct frustum-t)))
  (point (:pointer (:struct point3d-t))))

(export 'frustum-contains-point)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_intersects_sphere ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_intersects_sphere" frustum-intersects-sphere) :bool
 #+liber-documentation
 "@version{#2022-9-29}
  @argument[frustum]{a @symbol{frustum-t} instance to initialize}
  @argument[sphere]{a @symbol{sphere-t} instance}
  @return{@em{True} if the shpere intersects the frustum.}
  @begin{short}
    Checks whether the given sphere intersects a plane of the frustum.
  @end{short}
  @see-symbol{frustum-t}
  @see-symbol{point3d-t}"
  (frustum (:pointer (:struct frustum-t)))
  (sphere (:pointer (:struct sphere-t))))

(export 'frustum-intersects-sphere)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_intersects_box ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_intersects_box" frustum-intersects-box) :bool
 #+liber-documentation
 "@version{#2022-9-29}
  @argument[frustum]{a @symbol{frustum-t} instance to initialize}
  @argument[box]{a @symbol{box-t} instance}
  @return{@em{True} if the box intersects the frustum.}
  @begin{short}
    Checks whether the given box intersects a plane of the frustum.
  @end{short}
  @see-symbol{frustum-t}
  @see-symbol{box-t}"
  (frustum (:pointer (:struct frustum-t)))
  (box (:pointer (:struct box-t))))

(export 'frustum-intersects-box)

;;; ----------------------------------------------------------------------------
;;; graphene_frustum_equal ()
;;; ----------------------------------------------------------------------------

(defcfun ("graphene_frustum_equal" frustum-equal) :bool
 #+liber-documentation
 "@version{#2022-9-29}
  @argument[a]{a @symbol{frustum-t} instance}
  @argument[b]{a @symbol{frustum-t} instance}
  @return{@em{True} if the given frustums are equal.}
  @begin{short}
    Checks whether the given frustums are equal.
  @end{short}
  @see-symbol{frustum-t}"
  (a (:pointer (:struct frustum-t)))
  (b (:pointer (:struct frustum-t))))

(export 'frustum-equal)

;;; --- End of file graphene.frustum.lisp --------------------------------------
