;;;; -*- mode: Scheme; -*-

(define-record-type sdl-rect
  (fields x y w h))

(define-record-type sdl-point
  (fields x y))

(define-record-type sdl-renderer-info
  (fields name
	  flags
	  texture-formats
	  max-texture-width
	  max-texture-height))



(define (sdl-rect->ftype rect)
  (let*
      ((size (ftype-sizeof SDL_Rect))
       (addr (foreign-alloc size))
       (fptr (make-ftype-pointer SDL_Rect addr)))
    (ftype-set! SDL_Rect (x) fptr (sdl-rect-x rect))
    (ftype-set! SDL_Rect (y) fptr (sdl-rect-y rect))
    (ftype-set! SDL_Rect (w) fptr (sdl-rect-w rect))
    (ftype-set! SDL_Rect (h) fptr (sdl-rect-h rect))
    fptr))

(define (ftype->sdl-rect rect)
  (if (ftype-pointer-null? rect)
      '()
      (let ((return (make-sdl-rect (ftype-ref SDL_Rect (x) rect)
				   (ftype-ref SDL_Rect (y) rect)
				   (ftype-ref SDL_Rect (w) rect)
				   (ftype-ref SDL_Rect (h) rect))))
	(foreign-free (ftype-pointer-address rect))
	return)))


(define (sdl-point->ftype point)
  (let*
      ((size (ftype-sizeof SDL_Point))
       (addr (foreign-alloc size))
       (fptr (make-ftype-pointer SDL_Point addr)))
    (ftype-set! SDL_Point (x) fptr (sdl-point-x point))
    (ftype-set! SDL_Point (y) fptr (sdl-point-y point))
    fptr))

(define (ftype->sdl-point point)
  (error 'SDL-HELPER "Unimplemented" ftype->sdl-point))


(define (sdl-renderer-info->ftype info)
  (error 'SDL-HELPER "Unimplemented" sdl-renderer-info->ftype))

(define (ftype->sdl-renderer-info info)
  (define (get-formats count renderer-info)
    (define (loop index)
      (if (= index count)
	  '()
	  (cons (ftype-ref SDL_RendererInfo (texture_formats index) renderer-info)
		(loop (+ index 1)))))
    (loop 0))

  (define (read-string name)
    (define (loop index)
      (let ((c (ftype-ref char () name index)))
	(if (char=? c #\nul)
	    '()
	    (cons c (loop (+ index 1))))))
    (list->string (loop 0)))

  (make-sdl-renderer-info (read-string (ftype-ref SDL_RendererInfo (name) info))
			  (ftype-ref SDL_RendererInfo (flags) info)
			  (get-formats (ftype-ref SDL_RendererInfo (num_texture_formats) info) info)
			  (ftype-ref SDL_RendererInfo (max_texture_width)  info)
			  (ftype-ref SDL_RendererInfo (max_texture_height) info)))



(define sdl-show-window              SDL_ShowWindow)
(define sdl-destroy-window           SDL_DestroyWindow)
(define sdl-disable-screen-saver     SDL_DisableScreenSaver)
(define sdl-enable-screen-saver      SDL_EnableScreenSaver)
(define sdl-get-current-video-driver SDL_GetCurrentVideoDriver)
(define sdl-get-window-surface       SDL_GetWindowSurface)
(define sdl-get-display-name         SDL_GetDisplayName)
(define sdl-get-grabbed-window       SDL_GetGrabbedWindow)
(define sdl-get-num-display-modes    SDL_GetNumDisplayModes)
(define sdl-get-num-video-displays   SDL_GetNumVideoDisplays)
(define sdl-get-num-video-drivers    SDL_GetNumVideoDrivers)
(define sdl-get-video-driver         SDL_GetVideoDriver)
(define sdl-update-window-surface    SDL_UpdateWindowSurface)
(define sdl-gl-create-context        SDL_GL_CreateContext)
(define sdl-gl-delete-context        SDL_GL_DeleteContext)
(define sdl-gl-get-current-context   SDL_GL_GetCurrentContext)
(define sdl-gl-get-current-window    SDL_GL_GetCurrentWindow)
(define sdl-gl-get-swap-interval     SDL_GL_GetSwapInterval)
(define sdl-gl-make-current          SDL_GL_MakeCurrent)
(define sdl-gl-reset-attributes!     SDL_GL_ResetAttributes)
(define sdl-gl-set-attribute!        SDL_GL_SetAttribute)
(define sdl-gl-set-swap-interval!    SDL_GL_SetSwapInterval)
(define sdl-gl-swap-window           SDL_GL_SwapWindow)

(define (sdl-create-window title x y w h . flags)
  (SDL_CreateWindow title x y w h (fold-left bitwise-ior 0 flags)))

(define (sdl-gl-extension-supported? extension)
  (= SDL-TRUE (SDL_GL_ExtensionSupported extension)))

(define (sdl-gl-get-attribute attribute)
  (let*
      ((c-val (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
       (ret   (SDL_GL_GetAttribute attribute c-val))
       (value (ftype-ref int () c-val)))
    (foreign-free (ftype-pointer-address c-val))
    (if (= ret 0) value ret)))

(define (sdl-gl-get-drawable-size window)
  (let
      ((c-w (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
       (c-h (make-ftype-pointer int (foreign-alloc (ftype-sizeof int)))))
    (SDL_GL_GetDrawableSize window c-w c-h)
    (let
	((w (ftype-ref int () c-w))
	 (h (ftype-ref int () c-h)))
      (foreign-free (ftype-pointer-address c-w))
      (foreign-free (ftype-pointer-address c-h))
      (list w h))))

(define (sdl-get-display-bounds display-index)
  (let*
      ((c-rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect))))
       (ret (SDL_GetDisplayBounds display-index c-rect))
       (val (if (= ret 0)
		(make-sdl-rect (ftype-ref SDL_Rect (x) c-rect)
			       (ftype-ref SDL_Rect (y) c-rect)
			       (ftype-ref SDL_Rect (w) c-rect)
			       (ftype-ref SDL_Rect (h) c-rect))
		ret)))
    (foreign-free (ftype-pointer-address c-rect))
    val))

(define (sdl-get-display-dpi display-index)
  (let*
      ((c-ddpi (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
       (c-hdpi (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
       (c-vdpi (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
       (f-ret  (SDL_GetDisplayDPI display-index c-ddpi c-hdpi c-vdpi))
       (val (if (= f-ret 0)
		(list (ftype-ref float () c-ddpi)
		      (ftype-ref float () c-hdpi)
		      (ftype-ref float () c-vdpi))
		f-ret)))
    (foreign-free (ftype-pointer-address c-ddpi))
    (foreign-free (ftype-pointer-address c-hdpi))
    (foreign-free (ftype-pointer-address c-vdpi))
    val))

(define (sdl-get-display-usable-bounds display-index)
  (let*
      ((c-rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect))))
       (ret (SDL_GetDisplayUsableBounds display-index c-rect))
       (val (if (= ret 0)
		(make-sdl-rect (ftype-ref SDL_Rect (x) c-rect)
			       (ftype-ref SDL_Rect (y) c-rect)
			       (ftype-ref SDL_Rect (w) c-rect)
			       (ftype-ref SDL_Rect (h) c-rect))
		ret)))
    (foreign-free (ftype-pointer-address c-rect))
    val))



;;;          ;;;
;;; Renderer ;;;
;;;          ;;;

(define sdl-compose-custom-blend-mode SDL_ComposeCustomBlendMode)

(define (sdl-create-renderer window index . flags)
  (SDL_CreateRenderer window index (fold-left bitwise-ior 0 flags)))

(define sdl-create-software-renderer    SDL_CreateSoftwareRenderer)
(define sdl-create-texture              SDL_CreateTexture)
(define sdl-create-texture-from-surface SDL_CreateTextureFromSurface)
(define sdl-destroy-renderer            SDL_DestroyRenderer)
(define sdl-destroy-texture             SDL_DestroyTexture)

(define (sdl-gl-bind-texture texture)
  (let* ((texw (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
	 (texh (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
	 (return (if (= 0 (SDL_GL_BindTexture texture texw texh))
		     (cons (ftype-ref float () texw)
			   (ftype-ref float () texh))
		     '())))
    (foreign-free (ftype-pointer-address texw))
    (foreign-free (ftype-pointer-address texh))
    return))

(define sdl-gl-unbind-texture      SDL_GL_UnbindTexture)
(define sdl-get-num-render-drivers SDL_GetNumRenderDrivers)

(define (sdl-get-render-draw-blend-mode renderer)
(let* ((blend  (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
       (error  (SDL_GetRenderDrawBlendMode renderer blend))
       (return (if (= 0 error)
		   (ftype-ref int () blend)
		   error)))
  (foreign-free (ftype-pointer-address blend))
  return))

(define (sdl-get-render-draw-color renderer)
  (let* ((r      (make-ftype-pointer unsigned-8 (foreign-alloc 1)))
	 (g      (make-ftype-pointer unsigned-8 (foreign-alloc 1)))
	 (b      (make-ftype-pointer unsigned-8 (foreign-alloc 1)))
	 (a      (make-ftype-pointer unsigned-8 (foreign-alloc 1)))
	 (return (if (= 0 (SDL_GetRenderDrawColor renderer r g b a))
		     (list (ftype-ref unsigned-8 () r)
			   (ftype-ref unsigned-8 () g)
			   (ftype-ref unsigned-8 () b)
			   (ftype-ref unsigned-8 () a))
		     '())))
    (foreign-free (ftype-pointer-address r))
    (foreign-free (ftype-pointer-address g))
    (foreign-free (ftype-pointer-address b))
    (foreign-free (ftype-pointer-address a))
    return))

(define (sdl-get-render-driver-info index)
  (let* ((info   (make-ftype-pointer SDL_RendererInfo (foreign-alloc (ftype-sizeof SDL_RendererInfo))))
	 (error  (SDL_GetRenderDriverInfo index info))
	 (return (if (= 0 error)
		     (ftype->sdl-renderer-info info)
		     error)))
    (foreign-free (ftype-pointer-address info))
    return))

(define sdl-get-render-target SDL_GetRenderTarget)
(define sdl-get-renderer      SDL_GetRenderer)

(define (sdl-get-renderer-info renderer)
  (let* ((info   (make-ftype-pointer SDL_RendererInfo (foreign-alloc (ftype-sizeof SDL_RendererInfo))))
	 (error  (SDL_GetRendererInfo renderer info))
	 (return (if (= 0 error)
		     (ftype->sdl-renderer-info info)
		     error)))
    (foreign-free (ftype-pointer-address info))
    return))

(define (sdl-get-renderer-output-size renderer)
  (let* ((w      (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (h      (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (return (if (= 0 (SDL_GetRendererOutputSize renderer w h))
		     (cons (ftype-ref int () w)
			   (ftype-ref int () h))
		     '())))
    (foreign-free (ftype-pointer-address w))
    (foreign-free (ftype-pointer-address h))
    return))

(define (sdl-get-texture-alpha-mod texture)
  (let* ((alpha  (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (error  (SDL_GetTextureAlphaMod texture alpha))
	 (return (if (= 0 error)
		     (ftype-ref unsigned-8 () alpha)
		     error)))
    (foreign-free (ftype-pointer-address alpha))
    return))

(define (sdl-get-texture-blend-mode texture)
  (let* ((blend  (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (error  (SDL_GetTextureBlendMode texture blend))
	 (return (if (= 0 error)
		     (ftype-ref int () blend)
		     error)))
    (foreign-free (ftype-pointer-address blend))
    return))

(define (sdl-get-texture-color-mod texture)
  (let* ((r      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (g      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (b      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (return (if (= 0 (SDL_GetTextureColorMod texture r g b))
		     (list (ftype-ref unsigned-8 () r)
			   (ftype-ref unsigned-8 () g)
			   (ftype-ref unsigned-8 () b))
		     '())))
    (foreign-free (ftype-pointer-address r))
    (foreign-free (ftype-pointer-address g))
    (foreign-free (ftype-pointer-address b))
    return))

;; SDL_LockTexture  -- WILL NOT SUPPORT USE FTYPE
;; SDL_QueryTexture -- WILL NOT SUPPORT USE FTYPE

(define sdl-render-clear SDL_RenderClear)

(define (sdl-render-copy renderer texture src-rect dst-rect)
  (let* ((src    (if (sdl-rect? src-rect)
		     (sdl-rect->ftype src-rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (dst    (if (sdl-rect? dst-rect)
		     (sdl-rect->ftype dst-rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderCopy renderer texture src dst)))
    (if (sdl-rect? src-rect) (foreign-free (ftype-pointer-address src)))
    (if (sdl-rect? dst-rect) (foreign-free (ftype-pointer-address dst)))
    return))

(define (sdl-render-copy-ex renderer texture src-rect dst-rect angle center-point flip)
  (let* ((src    (if (sdl-rect? src-rect)
		     (sdl-rect->ftype src-rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (dst    (if (sdl-rect? dst-rect)
		     (sdl-rect->ftype dst-rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (center (if (sdl-point? center-point)
		     (sdl-point->ftype center-point)
		     (make-ftype-pointer SDL_Point 0)))
	 (return (SDL_RenderCopyEx renderer
				   texture
				   src dst
				   angle
				   center
				   flip)))
    (if (sdl-rect? src-rect)      (foreign-free (ftype-pointer-address src)))
    (if (sdl-rect? dst-rect)      (foreign-free (ftype-pointer-address dst)))
    (if (sdl-point? center-point) (foreign-free (ftype-pointer-address center)))
    return))

(define sdl-render-draw-line SDL_RenderDrawLine)

(define (sdl-render-draw-lines renderer points)
  (define (fill data count index points-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Point (x) data index (sdl-point-x (car points-list)))
	  (ftype-set! SDL_Point (y) data index (sdl-point-y (car points-list)))
	  (fill data count (+ index 1) (cdr points-list)))))
  (let* ((count (length points))
	 (chunk (make-ftype-pointer SDL_Point (foreign-alloc (* count (ftype-sizeof SDL_Point))))))
    (fill chunk count 0 points)
    (let ((return (SDL_RenderDrawLines renderer chunk count)))
      (foreign-free (ftype-pointer-address chunk))
      return)))

(define sdl-render-draw-point SDL_RenderDrawPoint)

(define (sdl-render-draw-points renderer points)
  (define (fill data count index points-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Point (x) data index (sdl-point-x (car points-list)))
	  (ftype-set! SDL_Point (y) data index (sdl-point-y (car points-list)))
	  (fill data count (+ index 1) (cdr points-list)))))
  (let* ((count (length points))
	 (chunk (make-ftype-pointer SDL_Point (foreign-alloc (* count (ftype-sizeof SDL_Point))))))
    (fill chunk count 0 points)
    (let ((return (SDL_RenderDrawPoints renderer chunk count)))
      (foreign-free (ftype-pointer-address chunk))
      return)))

(define (sdl-render-draw-rect renderer rect)
  (let* ((frect (if (sdl-rect? rect)
		    (sdl-rect->ftype rect)
		    (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderDrawRect renderer frect)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address frect)))
    return))

(define (sdl-render-draw-rects renderer rects)
  (define (fill data count index rects-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Rect (x) data index (sdl-rect-x (car rects-list)))
	  (ftype-set! SDL_Rect (y) data index (sdl-rect-y (car rects-list)))
	  (ftype-set! SDL_Rect (w) data index (sdl-rect-w (car rects-list)))
	  (ftype-set! SDL_Rect (h) data index (sdl-rect-h (car rects-list)))
	  (fill data count (+ index 1) (cdr rects-list)))))
  (let* ((count (length rects))
	 (chunk (make-ftype-pointer SDL_Rect (foreign-alloc (* count (ftype-sizeof SDL_Rect))))))
    (fill chunk count 0 rects)
    (let ((return (SDL_RenderDrawRects renderer chunk count)))
      (foreign-free (ftype-pointer-address chunk))
      return)))

(define (sdl-render-fill-rect renderer rect)
  (let* ((frect (if (sdl-rect? rect)
		    (sdl-rect->ftype rect)
		    (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderFillRect renderer frect)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address frect)))
    return))

(define (sdl-render-fill-rects renderer rects)
  (define (fill data count index rects-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Rect (x) data index (sdl-rect-x (car rects-list)))
	  (ftype-set! SDL_Rect (y) data index (sdl-rect-y (car rects-list)))
	  (ftype-set! SDL_Rect (w) data index (sdl-rect-w (car rects-list)))
	  (ftype-set! SDL_Rect (h) data index (sdl-rect-h (car rects-list)))
	  (fill data count (+ index 1) (cdr rects-list)))))
  (let* ((count (length rects))
	 (chunk (make-ftype-pointer SDL_Rect (foreign-alloc (* count (ftype-sizeof SDL_Rect))))))
    (fill chunk count 0 rects)
    (let ((return (SDL_RenderFillRects renderer chunk count)))
      (foreign-free (ftype-pointer-address chunk))
      return)))

(define (sdl-render-get-clip-rect renderer)
  (let ((rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect)))))
    (SDL_RenderGetClipRect renderer rect)
    (ftype->sdl-rect rect)))

(define (sdl-render-get-integer-scale renderer)
  (= (SDL_RenderGetIntegerScale renderer) SDL-TRUE))

(define (sdl-render-get-logical-size renderer)
  (let ((w (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	(h (make-ftype-pointer int (foreign-alloc (ftype-sizeof int)))))
    (SDL_RenderGetLogicalSize renderer w h)
    (let ((return (cons (ftype-ref int () w)
			(ftype-ref int () h))))
      (foreign-free (ftype-pointer-address w))
      (foreign-free (ftype-pointer-address h))
      return)))

(define (sdl-render-get-scale renderer)
  (let ((x (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
	(y (make-ftype-pointer float (foreign-alloc (ftype-sizeof float)))))
    (SDL_RenderGetScale renderer x y)
    (let ((return (cons (ftype-ref float () x)
			(ftype-ref float () y))))
      (foreign-free (ftype-pointer-address x))
      (foreign-free (ftype-pointer-address y))
      return)))

(define (sdl-render-get-viewport renderer)
  (let ((rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect)))))
    (SDL_RenderGetViewport renderer rect)
    (ftype->sdl-rect rect)))

(define (sdl-render-is-clip-enabled? renderer)
  (= (SDL_RenderIsClipEnabled renderer) SDL-TRUE))

(define sdl-render-present SDL_RenderPresent)

;; SDL_RenderReadPixels -- WILL NOT SUPPORT USE FTYPE

(define (sdl-render-set-clip! renderer rect)
  (let* ((clip   (if (sdl-rect? rect)
		     (sdl-rect->ftype rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderSetClipRect renderer clip)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address clip)))
    return))

(define sdl-render-set-integer-scale! SDL_RenderSetIntegerScale)
(define sdl-render-set-logical-size!  SDL_RenderSetLogicalSize)
(define sdl-render-set-scale!         SDL_RenderSetScale)

(define (sdl-render-set-viewport! renderer rect)
  (let* ((view   (if (sdl-rect? rect)
		     (sdl-rect->ftype rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderSetViewport renderer view)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address view)))
    return))

(define (sdl-render-target-supported? renderer)
  (= (SDL_RenderTargetSupported renderer) SDL-TRUE))

(define sdl-set-render-draw-blend-mode! SDL_SetRenderDrawBlendMode)
(define sdl-set-render-draw-color!      SDL_SetRenderDrawColor)

(define (sdl-set-render-target! renderer texture)
  (SDL_SetRenderTarget renderer (if (= 0 texture)
				    (make-ftype-pointer SDL_Texture 0)
				    texture)))

(define sdl-set-texture-alpha-mod!  SDL_SetTextureAlphaMod)
(define sdl-set-texture-blend-mode! SDL_SetTextureBlendMode)
(define sdl-set-texture-color-mod!  SDL_SetTextureColorMod)

;; SDL_UnlockTexture    -- WILL NOT SUPPORT USE FTYPE
;; SDL_UpdateTexture    -- WILL NOT SUPPORT USE FTYPE
;; SDL_UpdateYUVTexture -- WILL NOT SUPPORT USE FTYPE




;;;        ;;;
;;; Pixels ;;;
;;;        ;;;

(define sdl-map-rgb SDL_MapRGB)



;;;      ;;;
;;; Rect ;;;
;;;      ;;;

#|
(define (sdl-enclude-points points . clip)
  (let* ((func (foreign-procedure "SDL_EnclosePoints"
				  ((* SDL_Point)
				   int
				   (* SDL_Rect)
				   (* SDL_Rect))
				  int))
	 (c-result (make-ftype-pointer
		    SDL_Rect
		    (foreign-alloc (ftype-sizeof SDL_Rect))))
	 (count    (length points))
	 (c-points (points->c-points points count)))
    (if (null? clip)
	(let* ((error (func c-points
			    count
			    (make-ftype-pointer SDL_Rect 0)
			    c-result))
	       (result (if (= 1 error) (c-rect->rect c-result) '())))
	  (foreign-free (ftype-pointer-address c-result))
	  (foreign-free (ftype-pointer-address c-points))
	  result)
	(let* ((c-clip (rect->c-rect (car clip)))
	       (error  (func c-points
			     count
			     clip
			     c-result))
	       (result (if (= 1 error) (c-rect->rect c-result) '())))
	  (foreign-free (ftype-pointer-address c-clip))
	  (foreign-free (ftype-pointer-address c-result))
	  (foreign-free (ftype-pointer-address c-points))
	  result))))


(define (sdl-has-intersection? a b)
  (let* ((func (foreign-procedure "SDL_HasIntersection"
				  ((* SDL_Rect) (* SDL_Rect))
				  int))
	 (c-a (rect->c-rect a))
	 (c-b (rect->c-rect b))
	 (res (func c-a c-b)))
    (foreign-free (ftype-pointer-address c-a))
    (foreign-free (ftype-pointer-address c-b))
    (= 1 res)))


(define (sdl-intersect-rect a b)
  (let* ((func (foreign-procedure "SDL_IntersectRect"
				  ((* SDL_Rect)
				   (* SDL_Rect)
				   (* SDL_Rect))
				  int))
	 (c-a   (rect->c-rect a))
	 (c-b   (rect->c-rect b))
	 (c-res (make-ftype-pointer
		 SDL_Rect
		 (foreign-alloc (ftype-sizeof SDL_Rect))))
	 (has   (func c-a c-b c-res)))
    (foreign-free (ftype-pointer-address c-a))
    (foreign-free (ftype-pointer-address c-b))
    (foreign-free (ftype-pointer-address c-res))
    (if (= 1 has)
	(c-rect->rect c-res)
	'())))


(define (sdl-intersect-and-line rect x1 y1 x2 y2)
  (let ((func (foreign-procedure "SDL_IntersectRectAndLine"
				 ((* SDL_Rect)
				  (* int)
				  (* int)
				  (* int)
				  (* int))
				 int))
	(c-x1   (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	(c-y1   (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	(c-x2   (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	(c-y2   (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	(c-rect (rect->c-rect rect)))
    (ftype-set! int () c-x1 x1)
    (ftype-set! int () c-y1 y1)
    (ftype-set! int () c-x2 x2)
    (ftype-set! int () c-y2 y2)
    (let* ((has (func c-rect c-x1 c-y1 c-x2 c-y2))
	   (res (list (= 1 has)
		      (make-sdl-point c-x1 c-y1)
		      (make-sdl-point c-x2 c-y2))))
      (foreign-free (ftype-pointer-address c-x1))
      (foreign-free (ftype-pointer-address c-y1))
      (foreign-free (ftype-pointer-address c-x2))
      (foreign-free (ftype-pointer-address c-y2))
      (foreign-free (ftype-pointer-address c-rect))
      res)))


(define (sdl-point-in-rect? point rect)
  (let* ((func (foreign-procedure "SDL_PointInRect"
				  ((* SDL_Point) (* SDL_Rect))
				  int))
	 (c-point (point->c-point point))
	 (c-rect  (rect->c-rect rect))
	 (res     (func c-point c-rect)))
    (foreign-free (ftype-pointer-address c-point))
    (foreign-free (ftype-pointer-address c-rect))
    (= 1 res)))


(define (sdl-rect-empty? rect)
  (let* ((func (foreign-procedure "SDL_RectEmpty"
				  ((* SDL_Rect))
				  int))
	 (c-rect  (rect->c-rect rect))
	 (res     (func c-rect)))
    (foreign-free (ftype-pointer-address c-rect))
    (= 1 res)))


(define (sdl-rect-equal? a b)
  (let* ((func (foreign-procedure "SDL_RectEquals"
				  ((* SDL_Rect) (* SDL_Rect))
				  int))
	 (c-rect-a (rect->c-rect a))
	 (c-rect-b (rect->c-rect b))
	 (res     (func c-rect-a c-rect-b)))
    (foreign-free (ftype-pointer-address c-rect-a))
    (foreign-free (ftype-pointer-address c-rect-b))
    (= 1 res)))


(define (sdl-union-rect a b)
  (let* ((func (foreign-procedure "SDL_UnionRect"
				  ((* SDL_Rect)
				   (* SDL_Rect)
				   (* SDL_Rect))
				  void))
	 (c-rect-a (rect->c-rect a))
	 (c-rect-b (rect->c-rect b))
	 (c-union  (make-ftype-pointer
		    SDL_Rect
		    (foreign-alloc (ftype-sizeof SDL_Rect)))))
    (func c-rect-a
	  c-rect-b
	  c-union)
    (let ((union (c-rect->rect c-union)))
      (foreign-free (ftype-pointer-address c-rect-a))
      (foreign-free (ftype-pointer-address c-rect-b))
      (foreign-free (ftype-pointer-address c-union))
      union)))
|#



;;;          ;;;
;;; Surfaces ;;;
;;;          ;;;

(define sdl-free-surface SDL_FreeSurface)
(define sdl-load-bmp     SDL_LoadBMP)
(define sdl-fill-rect    SDL_FillRect)



;;;           ;;;
;;; Clipboard ;;;
;;;           ;;;

(define sdl-get-clipboard-text SDL_GetClipboardText)

(define (sdl-has-clipboard-text?) (= 1 (SDL_HasClipboardText)))

(define (sdl-set-clipboard-text! text) (= 1 (SDL_SetClipboardText text)))
