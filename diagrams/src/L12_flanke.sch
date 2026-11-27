{
 "inputs": {
  "taste": [
   40,
   40
  ],
  "clk": [
   40,
   60
  ],
  "res_n": [
   40,
   80
  ]
 },
 "outputs": {
  "puls": [
   420,
   130
  ]
 },
 "parts": {
  "ff": {
   "type": "dff",
   "x": 120,
   "y": 20,
   "label": "ff: d_ff"
  },
  "g1": {
   "type": "not",
   "x": 240,
   "y": 20,
   "label": "g1"
  },
  "g2": {
   "type": "and",
   "x": 330,
   "y": 100,
   "label": "g2"
  }
 },
 "wires": [
  [
   "taste",
   "ff.d"
  ],
  [
   "clk",
   "ff.c"
  ],
  [
   "res_n",
   "ff.r"
  ],
  [
   "ff.q",
   "g1.i0",
   {
    "label": "taste_d",
    "lx": 205,
    "hl": true,
    "ly": 34
   }
  ],
  [
   "taste",
   "g2.i0",
   {
    "via": [
     [
      70,
      40
     ],
     [
      70,
      120
     ]
    ],
    "dot": [
     70,
     40
    ]
   }
  ],
  [
   "g1.o",
   "g2.i1",
   {
    "mx": 305,
    "label": "taste_d_n",
    "lx": 318,
    "ly": 98,
    "hl": true
   }
  ],
  [
   "g2.o",
   "puls"
  ]
 ]
}