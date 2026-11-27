{
 "inputs": {
  "ser_in": [
   40,
   40
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
  "ser_out": [
   520,
   40
  ]
 },
 "parts": {
  "f0": {
   "type": "dff",
   "x": 110,
   "y": 20,
   "label": "q(0)"
  },
  "f1": {
   "type": "dff",
   "x": 210,
   "y": 20,
   "label": "q(1)"
  },
  "f2": {
   "type": "dff",
   "x": 310,
   "y": 20,
   "label": "q(2)"
  },
  "f3": {
   "type": "dff",
   "x": 410,
   "y": 20,
   "label": "q(3)"
  }
 },
 "wires": [
  [
   "ser_in",
   "f0.d"
  ],
  [
   "f0.q",
   "f1.d",
   {
    "hl": true
   }
  ],
  [
   "f1.q",
   "f2.d",
   {
    "hl": true
   }
  ],
  [
   "f2.q",
   "f3.d",
   {
    "hl": true
   }
  ],
  [
   "f3.q",
   "ser_out"
  ],
  [
   "clk",
   "f0.c",
   {
    "via": [
     [
      85,
      160
     ],
     [
      85,
      60
     ]
    ]
   }
  ],
  [
   "clk",
   "f1.c",
   {
    "via": [
     [
      185,
      160
     ],
     [
      185,
      60
     ]
    ],
    "dot": [
     85,
     160
    ]
   }
  ],
  [
   "clk",
   "f2.c",
   {
    "via": [
     [
      285,
      160
     ],
     [
      285,
      60
     ]
    ],
    "dot": [
     185,
     160
    ]
   }
  ],
  [
   "clk",
   "f3.c",
   {
    "via": [
     [
      385,
      160
     ],
     [
      385,
      60
     ]
    ],
    "dot": [
     285,
     160
    ]
   }
  ],
  [
   "res_n",
   "f0.r",
   {
    "via": [
     [
      78,
      180
     ],
     [
      78,
      80
     ]
    ]
   }
  ],
  [
   "res_n",
   "f1.r",
   {
    "via": [
     [
      178,
      180
     ],
     [
      178,
      80
     ]
    ],
    "dot": [
     78,
     180
    ]
   }
  ],
  [
   "res_n",
   "f2.r",
   {
    "via": [
     [
      278,
      180
     ],
     [
      278,
      80
     ]
    ],
    "dot": [
     178,
     180
    ]
   }
  ],
  [
   "res_n",
   "f3.r",
   {
    "via": [
     [
      378,
      180
     ],
     [
      378,
      80
     ]
    ],
    "dot": [
     278,
     180
    ]
   }
  ]
 ],
 "notes": [
  [
   40,
   215,
   "jede steigende Flanke: jedes Bit eine Stufe weiter Richtung MSB, sr <= sr(2 downto 0) & ser_in"
  ]
 ]
}