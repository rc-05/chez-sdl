;;;; -*- mode: Scheme; -*-

;;;;
;;;;
;;;;

(import (sdl))


(sdl-set-main-ready!)

(sdl-init SDL-INIT-VIDEO
	  SDL-INIT-EVENTS
	  SDL-INIT-JOYSTICK
	  SDL-INIT-GAMECONTROLLER)


(define *window*
  (sdl-create-window "chezscheme"
		     SDL-WINDOWPOS-UNDEFINED
		     SDL-WINDOWPOS-UNDEFINED
		     640
		     480
		     SDL-WINDOW-ALLOW-HIGHDPI))


(define (event-loop)
  ;; Put a new event in the library.
  (sdl-poll-event)
  (cond
   ((sdl-event-none?)            (event-loop))
   ((sdl-event-quit?)            '())
   ((sdl-event-drop-text?)       (printf (sdl-event-drop-file))
                                 (event-loop))
   ((sdl-event-mouse-motion?)    (printf "Current mouse position: (~d,~d)~n"
				         (sdl-event-mouse-motion-x)
				         (sdl-event-mouse-motion-y))
                                 (event-loop))
   ((sdl-event-key-up? SDLK-A)   (printf "A is released.~n")
                                 (event-loop))
   ((sdl-event-key-down? SDLK-A) (printf "A is pressed.~n")
                                 (event-loop))
   (else
    (event-loop))))


(event-loop)


(sdl-destroy-window *window*)
(sdl-quit)
