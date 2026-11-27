{
 "inputs": {
  "taste": [
   40,
   94
  ],
  "clk": [
   40,
   160
  ],
  "res_n": [
   40,
   180
  ]
 },
 "outputs": {
  "anzahl": [
   710,
   54
  ]
 },
 "parts": {
  "s": {
   "type": "block",
   "x": 110,
   "y": 20,
   "title": "synchronisierer",
   "in": [
    "clk",
    "res_n",
    "async_in"
   ],
   "out": [
    "sync_out"
   ],
   "w": 140,
   "label": "sync"
  },
  "f": {
   "type": "block",
   "x": 340,
   "y": 20,
   "title": "flanke_s",
   "in": [
    "clk",
    "res_n",
    "taste"
   ],
   "out": [
    "puls"
   ],
   "w": 110,
   "label": "edge"
  },
  "z": {
   "type": "block",
   "x": 560,
   "y": 20,
   "title": "zaehler4",
   "in": [
    "clk",
    "res_n",
    "en"
   ],
   "out": [
    "q"
   ],
   "w": 110,
   "label": "cnt"
  }
 },
 "wires": [
  [
   "taste",
   "s.async_in"
  ],
  [
   "s.sync_out",
   "f.taste",
   {
    "mx": 295,
    "label": "taste_sync",
    "lx": 300,
    "ly": 110,
    "hl": true
   }
  ],
  [
   "f.puls",
   "z.en",
   {
    "mx": 510,
    "label": "puls",
    "lx": 515,
    "ly": 110,
    "hl": true
   }
  ],
  [
   "z.q",
   "anzahl"
  ],
  [
   "clk",
   "s.clk",
   {
    "via": [
     [
      80,
      160
     ],
     [
      80,
      54
     ]
    ]
   }
  ],
  [
   "clk",
   "f.clk",
   {
    "via": [
     [
      310,
      160
     ],
     [
      310,
      54
     ]
    ],
    "dot": [
     80,
     160
    ]
   }
  ],
  [
   "clk",
   "z.clk",
   {
    "via": [
     [
      530,
      160
     ],
     [
      530,
      54
     ]
    ],
    "dot": [
     310,
     160
    ]
   }
  ],
  [
   "res_n",
   "s.res_n",
   {
    "via": [
     [
      90,
      180
     ],
     [
      90,
      74
     ]
    ]
   }
  ],
  [
   "res_n",
   "f.res_n",
   {
    "via": [
     [
      320,
      180
     ],
     [
      320,
      74
     ]
    ],
    "dot": [
     90,
     180
    ]
   }
  ],
  [
   "res_n",
   "z.res_n",
   {
    "via": [
     [
      540,
      180
     ],
     [
      540,
      74
     ]
    ],
    "dot": [
     320,
     180
    ]
   }
  ]
 ]
}