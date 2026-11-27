{
 "inputs": {
  "a": [
   40,
   54
  ],
  "b": [
   40,
   74
  ],
  "cin": [
   40,
   134
  ]
 },
 "outputs": {
  "s": [
   520,
   114
  ],
  "cout": [
   520,
   180
  ]
 },
 "parts": {
  "ha1": {
   "type": "block",
   "x": 120,
   "y": 20,
   "title": "halbaddierer",
   "in": [
    "a",
    "b"
   ],
   "out": [
    "s",
    "c"
   ],
   "w": 110,
   "label": "ha1"
  },
  "ha2": {
   "type": "block",
   "x": 280,
   "y": 80,
   "title": "halbaddierer",
   "in": [
    "a",
    "b"
   ],
   "out": [
    "s",
    "c"
   ],
   "w": 110,
   "label": "ha2"
  },
  "g1": {
   "type": "or",
   "x": 430,
   "y": 150,
   "label": "g1: or_2"
  }
 },
 "wires": [
  [
   "a",
   "ha1.a"
  ],
  [
   "b",
   "ha1.b"
  ],
  [
   "ha1.s",
   "ha2.a",
   {
    "mx": 255,
    "label": "s1",
    "lx": 244,
    "hl": true
   }
  ],
  [
   "cin",
   "ha2.b"
  ],
  [
   "ha1.c",
   "g1.i0",
   {
    "via": [
     [
      245,
      74
     ],
     [
      245,
      170
     ]
    ],
    "label": "c1",
    "lx": 236,
    "ly": 160,
    "hl": true
   }
  ],
  [
   "ha2.s",
   "s"
  ],
  [
   "ha2.c",
   "g1.i1",
   {
    "mx": 410,
    "label": "c2",
    "lx": 400,
    "hl": true
   }
  ],
  [
   "g1.o",
   "cout"
  ]
 ]
}