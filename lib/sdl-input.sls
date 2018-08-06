;;;; -*- mode: Scheme; -*-

;;;;
;;;;
;;;;

(define SDL-SYSTEM-CURSOR-ARROW     0)
(define SDL-SYSTEM-CURSOR-IBEAM     1)
(define SDL-SYSTEM-CURSOR-WAIT      2)
(define SDL-SYSTEM-CURSOR-CROSSHAIR 3)
(define SDL-SYSTEM-CURSOR-WAITARROW 4)
(define SDL-SYSTEM-CURSOR-SIZENWSE  5)
(define SDL-SYSTEM-CURSOR-SIZENESW  6)
(define SDL-SYSTEM-CURSOR-SIZEWE    7)
(define SDL-SYSTEM-CURSOR-SIZENS    8)
(define SDL-SYSTEM-CURSOR-SIZEALL   9)
(define SDL-SYSTEM-CURSOR-NO       10)
(define SDL-SYSTEM-CURSOR-HAND     11)

(define-ftype sdl-c-cursor
  (struct
   [type unsigned-32]))

(define-ftype sdl-c-joystick
  (struct
   [type unsigned-32]))

(define-ftype sdl-c-game-controller
  (struct
   [type unsigned-32]))

(define-ftype sdl-c-finger
  (struct
   [id       integer-64]
   [x        float]
   [y        float]
   [pressure float]))

(define-record-type sdl-finger
  (fields id x y p))



;;;
;;;
;;;


(define sdl-get-key-from-name
  (foreign-procedure "SDL_GetKeyFromName" (string) int))

(define sdl-get-key-from-scancode
  (foreign-procedure "SDL_GetKeyFromScancode" (int) int))

(define sdl-get-key-name
  (foreign-procedure "SDL_GetKeyName" (int) string))

(define sdl-get-keyboard-focus
  (foreign-procedure "SDL_GetKeyboardFocus" () (* sdl-c-window)))

(define (sdl-get-keyboard-state)
  (let
      ([keys
	((foreign-procedure "SDL_GetKeyboardState" (void*) (* unsigned-8)) 0)])
    (lambda (key)
      (= 1 (ftype-ref unsigned-8 () keys key)))))

(define sdl-get-mod-state
  (foreign-procedure "SDL_GetModState" () int))

(define sdl-get-scancode-from-key
  (foreign-procedure "SDL_GetScancodeFromKey" (int) int))

(define sdl-get-scancode-from-name
  (foreign-procedure "SDL_GetScancodeFromName" (string) int))

(define sdl-get-scancode-name
  (foreign-procedure "SDL_GetScancodeName" (int) string))

(define _sdl-has-screen-keyboard-support?
  (foreign-procedure "SDL_HasScreenKeyboardSupport" () int))

(define (sdl-has-screen-keyboard-support?)
  (= 1 _sdl-has-screen-keyboard-support?))

(define _sdl-is-screen-keyboard-shown?
  (foreign-procedure "SDL_IsScreenKeyboardShown" ((* sdl-c-window)) int))

(define (sdl-is-screen-keyboard-shown?)
  (= 1 _sdl-is-screen-keyboard-shown?))

(define _sdl-is-text-input-active?
  (foreign-procedure "SDL_IsTextInputActive" () int))

(define (sdl-is-text-input-active?)
  (= 1 _sdl-is-text-input-active?))

(define sdl-set-mod-state!
  (foreign-procedure "SDL_SetModState" (int) void))

(define _sdl-set-text-input-rect!
  (foreign-procedure "SDL_SetTextInputRect" ((* sdl-c-rect)) void))

;; TODO: sdl-set-text-input-rect!
(define (sdl-set-text-input-rect!)
  (error 'SDL-INPUT "not implemented" sdl-set-text-input-rect!))

(define sdl-start-text-input
  (foreign-procedure "SDL_StartTextInput" () void))

(define sdl-stop-text-input
  (foreign-procedure "SDL_StopTextInput" () void))




;;;
;;;
;;;


(define _sdl-capture-mouse
  (foreign-procedure "SDL_CaptureMouse" (int) int))

(define (sdl-capture-mouse enable)
  (= 0 (_sdl-capture-mouse (if enable 1 0))))

(define sdl-create-color-cursor
  (foreign-procedure "SDL_CreateColorCursor" ((* sdl-c-surface) int int) (* sdl-c-cursor)))

(define sdl-create-system-cursor
  (foreign-procedure "SDL_CreateSystemCursor" (int) (* sdl-c-cursor)))

(define sdl-free-cursor
  (foreign-procedure "SDL_FreeCursor" ((* sdl-c-cursor)) void))

(define sdl-get-cursor
  (foreign-procedure "SDL_GetCursor" () (* sdl-c-cursor)))

(define sdl-show-cursor
  (foreign-procedure "SDL_ShowCursor" (int) int))

(define sdl-get-mouse-focus
  (foreign-procedure "SDL_GetMouseFocus" () (* sdl-c-window)))

(define sdl-get-default-cursor
  (foreign-procedure "SDL_GetDefaultCursor" () (* sdl-c-cursor)))

(define sdl-warp-mouse-in-window
  (foreign-procedure "SDL_WarpMouseInWindow" ((* sdl-c-window) int int) void))

(define sdl-warp-mouse-global
  (foreign-procedure "SDL_WarpMouseGlobal" (int int) int))

(define sdl-set-cursor!
  (foreign-procedure "SDL_SetCursor" ((* sdl-c-cursor)) void))

(define _sdl-set-relative-mouse-mode!
  (foreign-procedure "SDL_SetRelativeMouseMode" (int) int))

(define (sdl-set-relative-mouse-mode! enable)
  (= 0 (_sdl-set-relative-mouse-mode! (if enable 1 0))))

(define _sdl-get-relative-mouse-mode
  (foreign-procedure "SDL_GetRelativeMouseMode" () int))

(define (sdl-get-relative-mouse-mode)
  (= 1 (_sdl-get-relative-mouse-mode)))

;; TODO: CreateCursor,
;;       GetRelativeMouseState,
;;       GetGlobalMouseState,
;;       GetMouseState


(define sdl-joystick-open
  (foreign-procedure "SDL_JoystickOpen" (int) (* sdl-c-joystick)))

(define sdl-joystick-close
  (foreign-procedure "SDL_JoystickClose" ((* sdl-c-joystick)) void))

(define sdl-joystick-num
  (foreign-procedure "SDL_NumJoysticks" () int))

(define _sdl-joystick-current-power-level
  (foreign-procedure "SDL_JoystickCurrentPowerLevel" ((* sdl-c-joystick)) int))

(define (sdl-joystick-current-power-level joystick)
  (let ((level (_sdl-joystick-current-power-level joystick)))
    (cond
     ((= level -1) 'SDL-JOYSTICK-POWER-UNKNOWN)
     ((= level  0) 'SDL-JOYSTICK-POWER-EMPTY)
     ((= level  1) 'SDL-JOYSTICK-POWER-LOW)
     ((= level  2) 'SDL-JOYSTICK-POWER-MEDIUM)
     ((= level  3) 'SDL-JOYSTICK-POWER-FULL)
     ((= level  4) 'SDL-JOYSTICK-POWER-WIRED)
     ((= level  5) 'SDL-JOYSTICK-POWER-MAX)
     (else '()))))

(define sdl-joystick-event-state
  (foreign-procedure "SDL_JoystickEventState" (int) int))

(define sdl-joystick-from-instance-id
  (foreign-procedure "SDL_JoystickFromInstanceID"
		     (integer-32)
		     (* sdl-c-joystick)))

(define _sdl-joystick-get-attached
  (foreign-procedure "SDL_JoystickGetAttached" ((* sdl-c-joystick)) int))

(define (sdl-joystick-get-attached joystick)
  (= 1 (_sdl-joystick-get-attached joystick)))

(define sdl-joystick-get-axis
  (foreign-procedure "SDL_JoystickGetAxis" ((* sdl-c-joystick) int) integer-16))

(define _sdl-joystick-get-ball
  (foreign-procedure "SDL_JoystickGetBall"
		     ((* sdl-c-joystick) int (* int) (* int))
		     int))

(define (sdl-joystick-get-ball joystick ball)
  (let* ((dx   (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (dy   (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (err  (_sdl-joystick-get-ball joystick ball dx dy))
	 (dpos (list dx dy)))
    ;; Release allocated memory
    (foreign-free (ftype-pointer-address dx))
    (foreign-free (ftype-pointer-address dy))
    (if (= err 0)
	dpos
	'())))

(define sdl-joystick-get-button
  (foreign-procedure "SDL_JoystickGetButton"
		     ((* sdl-c-joystick) int)
		     unsigned-8))

(define _sdl-joystick-get-hat
  (foreign-procedure "SDL_JoystickGetHat" ((* sdl-c-joystick) int) unsigned-8))

(define (sdl-joystick-get-hat joystick index)
  (define SDL_HAT_CENTERED    #x00)
  (define SDL_HAT_UP          #x01)
  (define SDL_HAT_RIGHT       #x02)
  (define SDL_HAT_DOWN        #x04)
  (define SDL_HAT_LEFT        #x08)
  (define SDL_HAT_RIGHTUP     (bitwise-ior SDL_HAT_RIGHT SDL_HAT_UP))
  (define SDL_HAT_RIGHTDOWN   (bitwise-ior SDL_HAT_RIGHT SDL_HAT_DOWN))
  (define SDL_HAT_LEFTUP      (bitwise-ior SDL_HAT_LEFT  SDL_HAT_UP))
  (define SDL_HAT_LEFTDOWN    (bitwise-ior SDL_HAT_LEFT  SDL_HAT_DOWN))
  (let ([pos (_sdl-joystick-get-hat joystick index)])
    (cond
     ((= pos SDL_HAT_CENTERED)  'SDL-HAT-CENTERED)
     ((= pos SDL_HAT_UP)        'SDL-HAT-UP)
     ((= pos SDL_HAT_RIGHT)     'SDL-HAT-RIGHT)
     ((= pos SDL_HAT_DOWN)      'SDL-HAT-DOWN)
     ((= pos SDL_HAT_LEFT)      'SDL-HAT-LEFT)
     ((= pos SDL_HAT_RIGHTUP)   'SDL-HAT-RIGHT-UP)
     ((= pos SDL_HAT_RIGHTDOWN) 'SDL-HAT-RIGHT-DOWN)
     ((= pos SDL_HAT_LEFTUP)    'SDL-HAT-LEFT-UP)
     ((= pos SDL_HAT_LEFTDOWN)  'SDL-HAT-LEFT-DOWN)
     (else '()))))

(define sdl-joystick-instance-id
  (foreign-procedure "SDL_JoystickInstanceID"
		     ((* sdl-c-joystick))
		     integer-32))

(define sdl-joystick-name
  (foreign-procedure "SDL_JoystickName" ((* sdl-c-joystick)) string))

(define sdl-joystick-name-for-index
  (foreign-procedure "SDL_JoystickNameForIndex" (int) string))

(define sdl-joystick-num-axes
  (foreign-procedure "SDL_JoystickNumAxes" ((* sdl-c-joystick)) int))

(define sdl-joystick-num-balls
  (foreign-procedure "SDL_JoystickNumBalls" ((* sdl-c-joystick)) int))

(define sdl-joystick-num-buttons
  (foreign-procedure "SDL_JoystickNumButtons" ((* sdl-c-joystick)) int))

(define sdl-joystick-num-hats
  (foreign-procedure "SDL_JoystickNumHats" ((* sdl-c-joystick)) int))


;; TODO: GUID function

;;;
;;;
;;;


(define sdl-get-num-touch-devices
  (foreign-procedure "SDL_GetNumTouchDevices" () int))

(define sdl-get-touch-device
  (foreign-procedure "SDL_GetTouchDevice" (int) integer-64))

(define sdl-get-num-touch-fingers
  (foreign-procedure "SDL_GetNumTouchFingers" (integer-64) int))

(define _sdl-get-touch-finger
  (foreign-procedure "SDL_GetTouchFinger" (integer-64 int) (* sdl-c-finger)))

(define (sdl-get-touch-finger touch-id index)
  (let ((finger (_sdl-get-touch-finger touch-id index)))
    (make-sdl-finger (ftype-ref sdl-c-finger (id)       finger)
		     (ftype-ref sdl-c-finger (x)        finger)
		     (ftype-ref sdl-c-finger (y)        finger)
		     (ftype-ref sdl-c-finger (pressure) finger))))