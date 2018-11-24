breed [passengers passenger]
breed [staff-members staff-member]
breed [drivers driver]
breed [fire-spots a-fire-spot]
breed [smoke-spots a-smoke-spot]
breed [fire-distinguishers a-fire-distinguisher]
globals [ exit1 exit2 exit3 exit4 exit5 exit6 exit7 exit8 exits-list max-x max-y min-x min-y]

passengers-own [
  in-seat?
  safe?
  health
  panic?
  current-heading
  target-exit
  my-exits-list
]

staff-members-own [
  busy-staff?
  safe-staff?
  health-staff?
  target-fire
]

patches-own[
  busy-patche?
  accessible?
  withFire-patche?
]

fire-distinguishers-own [
  taken?
]

fire-spots-own [
  health
]

to setup
  __clear-all-and-reset-ticks
  initialize-train
  initialize-passengers
  initialize-staff
  initialize-fire
  initialize-exists
  set-target-exists
  initialize-borders
  reset-ticks
end

to go
  let passengers-in-seat (passengers with [in-seat? = true])
  spread-fire
  spread-smoke
  move-passengers
  ;;move-panic-passengers
  move-panic-passenger
  move-staff-members
  if (count fire-spots = 0)
  [
    stop
  ]
  tick
end

to initialize-borders
set max-y 48
set min-y -55
set max-x 459
set min-x -478
end

to initialize-train
  import-pcolors "images/train.png"
  ask patches [
  if pcolor = 87.1 or pcolor = 85
    [set pcolor cyan]
  if pcolor = 0
    [set pcolor black]
  if pcolor = 105
    [set pcolor blue]
  if pcolor = 64.3
    [set pcolor green]
  if pcolor = 9.9
    [set pcolor white]
  if pcolor = 135 or pcolor = 137.1
    [set pcolor pink]
  if pcolor = 126
    [set pcolor magenta]
  set withFire-patche? false
  ]

  ask patches [
    set accessible? false
  ]

  ask patches with [pxcor <  459 and pxcor > -478 and pycor > -50 and pycor < 50 ]
  [
    set accessible? true
  ]
end

to initialize-passengers


  create-passengers passenger-count [
    set shape "person business"
    set color brown
    setxy random-xcor random-ycor
    set size 18
    set safe? false
    set in-seat? true
    set target-exit ""
    set color yellow
    set panic? false
    set health 100
    move-to one-of patches with [ pcolor = blue ]
  ]

  ask passengers [
    let empty-seats patches with [ pcolor = blue ] with [not any? turtles-here ]
    if any? empty-seats
    [
      let target one-of empty-seats
      face target
      move-to target
      ask patches in-radius 6 [ set pcolor white ]
    ]
  ]

  ask n-of (panic-rate * passenger-count / 100) passengers [
    set panic? true
    set color red
    set current-heading (random 360)
  ]
end


to initialize-staff
  create-staff-members staff-count [
    set shape "person service"
    set color red
    setxy random-xcor random-ycor
    set size 18
    move-to one-of patches
  ]
  ask staff-members [
    let empty-seats patches with [ pcolor = green ] with [not any? turtles-here ]
    if any? empty-seats
    [
      let target one-of empty-seats
      face target
      move-to target
      ask patches in-radius 6 [ set pcolor white ]
    ]
  ]
end

to initialize-fire
  ask n-of fire-count patches with [pcolor = black or pcolor = white] with [pycor < 45 and pycor > -45 ]
  [
      sprout-fire-spots 1
      [
      set shape "fire"
      set color red
      set size 20
      set withFire-patche? true
      ]
  ]
end


to initialize-exists
  set exit1 patch -300 50
  set exit2 patch -175 50
  set exit3 patch 150 50
  set exit4 patch 280 50
  set exit5 patch -300 -50
  set exit6 patch -175 -50
  set exit7 patch 150 -50
  set exit8 patch 280 -50

  set exits-list ( list exit1 exit2 exit3 exit4 exit5 exit6 exit7 exit8 )
end


to spread-fire
  ask n-of 1 patches with [withFire-patche?]
  [
    ask n-of 1 patches in-radius 10 with [pycor > -45 and pycor < 45] [
      sprout-fire-spots 2 [
        set shape "fire"
        set color red
        set size 20
        set withFire-patche? true
      ]
    ]
  ]
end


to spread-smoke
  ask fire-spots [
    ask patches in-radius 10 [
       set pcolor grey
    ]
  ]
end

to set-target-exists
   ask passengers [
    let target min-one-of (patch-set exits-list) [distance myself]
    set target-exit target
    set my-exits-list exits-list
  ]

  ask passengers with [panic?]
  [
    let target min-one-of (patch-set exits-list) [distance myself]
    set target-exit target
    set my-exits-list exits-list
  ]
end
to update-panic-status
if ((random-float 1) * 100) <= probability-to-get-panic [
        set panic? true
        set color red
        set my-exits-list exits-list
      ]
end

to change-dir
  right 180
  forward 2
end

to update-my-exit
  set my-exits-list remove target-exit my-exits-list
  ifelse (any? (patch-set my-exits-list))
  [
    let new-target min-one-of (patch-set my-exits-list) [distance myself]
    set target-exit new-target
  ]
  [
    set my-exits-list exits-list
  ]
end
to move-passengers
  ask passengers with [safe? = false and panic? = false]
  [
    ifelse (fire-around-me)
    [
      update-health
      update-panic-status
      change-dir
      update-my-exit
    ]
    [
      ifelse ( ycor != 1 or ycor != -1 ) and (in-seat? = true)
      [
        go-to-main-path
      ]
      [
        move-to-exit
      ]
    ]
  ]
end

to go-to-main-path

;; If you are up, go down
  if ( member? target-exit ( patch-set exit1 exit2 exit3 exit4 ) )
      [
        let center patch xcor 1
        face center
        ifelse (ycor > 1)
        [
          forward 0.5
        ]
        [
          set in-seat? false
        ]
      ]
;; If you are down, go up
  if ( member? target-exit ( patch-set exit5 exit6 exit7 exit8 ) )
      [
        let center patch xcor -1
        face center
        ifelse (ycor < -1)
        [
          forward 0.5
        ]
        [
          set in-seat? false
        ]
      ]
end

to move-to-exit
  ;; If the exit is on the LEFT of agent,
  ;; then the agent must move to left until his XCOR greater by margin=20 than EXIT-X
  ;; then he should move UP or DOWN toward the exit.
  ifelse (xcor > ([pxcor] of target-exit))
  [
    let target-x ([pxcor] of target-exit)
    facexy target-x 1
    ifelse (xcor > target-x + 35)
    [
       ifelse ( [accessible?] of patch-ahead 1  )
      [
        forward 0.5
      ][
        right 90
        set panic? true
        set color red
      ]
    ]
    [
      face target-exit
      ifelse ( (round xcor) != ([pxcor] of target-exit))
      [
        forward 0.5
      ]
      [
        set color green
        move-to one-of patches in-radius 30 with [pcolor = cyan]
        set safe? true

      ]

    ]
  ]
  ;; ELSE, if the exit on the RIGHT of agent,
  ;; then agent must move to right until his XCOR smaller by margin=20 than EXIT-X
  ;; then he should move UP or DOWN toward the exit
  [
    let target-x ([pxcor] of target-exit)
    facexy target-x 1
    ifelse (xcor < target-x - 35)
    [
       ifelse ( [accessible?] of patch-ahead 1  )
      [
        forward 0.5
      ][
        right 90
        set panic? true
        set color red
      ]
    ]
    [
      face target-exit
      ifelse ( (round xcor) != ([pxcor] of target-exit))
      [
        forward 0.5
      ]
      [
        set color green
        move-to one-of patches in-radius 30 with [pcolor = cyan]
        set safe? true

      ]
    ]
  ]
end

to-report get-headings-list
  let dirs []
  if [pycor] of (patch-at 0 1) < 48
  [ set dirs lput (random 90) dirs ]
  if [pxcor] of (patch-at 1 0) < 459
  [ set dirs lput ((random 90) + 90)  dirs ]
  if [pycor] of (patch-at 0 -1) > -55
  [ set dirs lput ((random 90) + 180) dirs ]
  if [pxcor] of (patch-at -1 0) > -478
  [ set dirs lput ((random 90) + 270) dirs ]
  report dirs
end

to update-health
  ifelse (health > 10)[
      set health (health - 10)
    ]
   [
      set color black
      set safe? true
    ]

end

to move-panic-passenger
  ask passengers with [safe? = false and panic? = true]
  [
    set in-seat? false
    ifelse (fire-around-me)
    [
      update-health
      panic-change-dir
      panic-move-away
    ]
    [
      ifelse (close-to-exits)
      [
        panic-move-to-closest-exit
      ]
      [
        panic-move-randomly
      ]
    ]
  ]
end

to-report fire-around-me
  let fires-around-me patches in-radius 16 with [withFire-patche?]
  if any? fires-around-me
  [
    report true
  ]
  report false
end

to panic-change-dir
  right 180
  set heading (one-of get-headings-list)
end

to panic-move-away
  forward 2
  set my-exits-list remove target-exit my-exits-list
  ifelse (any? (patch-set my-exits-list))
  [
    let new-target min-one-of (patch-set my-exits-list) [distance myself]
    set target-exit new-target
  ]
  [
    set my-exits-list exits-list
  ]
end

to-report close-to-exits
   let closest-exits patches in-radius 16 with [pcolor = pink]
   if (any? closest-exits)[
    report true
  ]
  report false
end

to panic-move-to-closest-exit
  face target-exit
  ifelse ( (round xcor) = ([pxcor] of target-exit) and (round ycor) = ([pycor] of target-exit))
        [

          set color green
          let cyan-around patches in-radius 16 with [pcolor = cyan]
          if any? cyan-around
          [
            move-to one-of cyan-around
            set safe? true
          ]
        ]
  [
      forward 1
  ]
end

to panic-move-randomly

  ifelse ( (round xcor) = ([pxcor] of target-exit) and (round ycor) = ([pycor] of target-exit))
  [
    set color green
    let cyan-around patches in-radius 8 with [pcolor = cyan]
    if any? cyan-around
    [
     move-to one-of cyan-around
     set safe? true
    ]
  ]
  [
    ifelse ( [accessible?] of patch-ahead 1  )
    [forward 2]
    [
      set heading (one-of get-headings-list)
      forward 2
    ]
  ]
end

to set-target-fire
  let possible-targets patch-set patches with [ withFire-patche?]
  if (any? possible-targets )
  [
    let target min-one-of (possible-targets) [distance myself]
    set target-fire target
  ]
end

to decriase-fire-health
  if (any? fire-spots-on target-fire)
  [
     ask fire-spots-on target-fire [
      set withFire-patche? false
      die]

  ]

  if (any? smoke-spots-on target-fire)
  [
     ask smoke-spots-on target-fire [die]
  ]
end

to move-staff-members
  ask staff-members [
    let count-fire-spots (count fire-spots)
    ifelse (any? fire-spots)
  [
      set-target-fire
      face target-fire


      if (distance target-fire > 30)[
        forward 2
      ]
      if (distance target-fire < 30)[
        decriase-fire-health
      ]
    ]
    [;;else statement
   ;;exit from train
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1419
420
-1
-1
1.0
1
10
1
1
1
0
1
1
1
-600
600
-200
200
1
1
1
ticks
30.0

BUTTON
29
26
92
59
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
103
26
166
59
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
72
185
105
passenger-count
passenger-count
0
60
60.0
1
1
NIL
HORIZONTAL

SLIDER
14
121
186
154
staff-count
staff-count
0
8
8.0
1
1
NIL
HORIZONTAL

SLIDER
14
172
186
205
drivers-count
drivers-count
0
2
1.0
1
1
NIL
HORIZONTAL

SLIDER
14
221
186
254
fire-count
fire-count
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
14
271
186
304
panic-rate
panic-rate
0
100
30.0
5
1
%
HORIZONTAL

SLIDER
13
324
189
357
probability-to-get-panic
probability-to-get-panic
0
100
0.0
5
1
%
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
