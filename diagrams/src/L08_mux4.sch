{
 "inputs": {
  "d(0)": [
   40,
   54
  ],
  "d(1)": [
   40,
   74
  ],
  "d(2)": [
   40,
   174
  ],
  "d(3)": [
   40,
   194
  ],
  "sel(0)": [
   40,
   250
  ],
  "sel(1)": [
   40,
   280
  ]
 },
 "outputs": {
  "y": [
   430,
   114
  ]
 },
 "parts": {
  "lo": {
   "type": "block",
   "x": 140,
   "y": 20,
   "title": "mux2",
   "in": [
    "a",
    "b",
    "sel"
   ],
   "out": [
    "y"
   ],
   "w": 90,
   "label": "m_lo"
  },
  "hi": {
   "type": "block",
   "x": 140,
   "y": 140,
   "title": "mux2",
   "in": [
    "a",
    "b",
    "sel"
   ],
   "out": [
    "y"
   ],
   "w": 90,
   "label": "m_hi"
  },
  "out": {
   "type": "block",
   "x": 310,
   "y": 80,
   "title": "mux2",
   "in": [
    "a",
    "b",
    "sel"
   ],
   "out": [
    "y"
   ],
   "w": 90,
   "label": "m_out"
  }
 },
 "wires": [
  [
   "d(0)",
   "lo.a"
  ],
  [
   "d(1)",
   "lo.b"
  ],
  [
   "d(2)",
   "hi.a"
  ],
  [
   "d(3)",
   "hi.b"
  ],
  [
   "sel(0)",
   "lo.sel",
   {
    "via": [
     [
      100,
      250
     ],
     [
      100,
      94
     ]
    ]
   }
  ],
  [
   "sel(0)",
   "hi.sel",
   {
    "via": [
     [
      100,
      250
     ],
     [
      100,
      214
     ]
    ],
    "dot": [
     100,
     214
    ]
   }
  ],
  [
   "sel(1)",
   "out.sel",
   {
    "via": [
     [
      280,
      280
     ],
     [
      280,
      154
     ]
    ]
   }
  ],
  [
   "lo.y",
   "out.a",
   {
    "mx": 270,
    "label": "y_lo",
    "lx": 252,
    "hl": true
   }
  ],
  [
   "hi.y",
   "out.b",
   {
    "mx": 260,
    "label": "y_hi",
    "lx": 247,
    "hl": true
   }
  ],
  [
   "out.y",
   "y"
  ]
 ]
}