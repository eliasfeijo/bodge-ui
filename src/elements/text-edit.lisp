(cl:in-package :bodge-ui)

;;;
;;;
;;;
(defclass text-edit (disposable widget)
  ((buffer :initform (claw:calloc '(:struct (%nk:text-edit))))))


(defmethod initialize-instance :after ((this text-edit) &key)
  (with-slots (buffer) this
    (%nk:textedit-init-default buffer)))


(define-destructor text-edit (buffer)
  (claw:free buffer))


(defun make-text-edit (&key name)
  (make-instance 'text-edit :name name))


(defmethod text-of ((this text-edit))
  (with-slots (buffer) this
    (claw:c-let ((buf (:struct (%nk:text-edit)) :from buffer))
      (let* ((str-info (buf :string))
             (len (%nk:str-len-char str-info)))
        (if-let ((ptr (%nk:str-get-const str-info)))
          (cffi:foreign-string-to-lisp ptr :count len
                                           :encoding :utf-8)
          "")))))


(defmethod (setf text-of) ((value string) (this text-edit))
  (with-slots (buffer) this
    (claw:c-let ((buf (:struct (%nk:text-edit)) :from buffer))
      (let ((str-info (buf :string)))
        (%nk:str-clear str-info)
        (unless (alexandria:emptyp value)
          (cffi:with-foreign-string (string-ptr value :encoding :utf-8)
            (%nk:str-append-text-utf8 str-info string-ptr (length value))))))
    value))


(defmethod compose ((this text-edit))
  (with-slots (buffer) this
    (%nk:edit-buffer *handle* %nk:+edit-simple+ buffer
                     (claw:foreign-function-pointer '%nk:filter-default))))
