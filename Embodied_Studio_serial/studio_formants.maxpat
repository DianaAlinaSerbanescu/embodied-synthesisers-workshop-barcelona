{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 8,
      "minor": 6,
      "revision": 0,
      "architecture": "x64",
      "modernui": 1
    },
    "rect": [
      80,
      80,
      1100,
      750
    ],
    "default_fontsize": 12.0,
    "default_fontname": "Arial",
    "boxes": [
      {
        "box": {
          "id": "title",
          "maxclass": "comment",
          "patching_rect": [
            30,
            20,
            800,
            22
          ],
          "fontsize": 20.0,
          "text": "EMBODIED FORMANTS \u2014 MAX AUDIO ENGINE"
        }
      },
      {
        "box": {
          "id": "info",
          "maxclass": "comment",
          "patching_rect": [
            30,
            55,
            1000,
            22
          ],
          "text": "Run the Processing controller. Press D there to enable/silence sound; use 1/2, R/S, M/Q/W there."
        }
      },
      {
        "box": {
          "id": "info2",
          "maxclass": "comment",
          "patching_rect": [
            30,
            80,
            1000,
            22
          ],
          "text": "New voice per physical gesture; stable during sustain. Independent A0/A1 vowel paths. OSC timeout: 500 ms."
        }
      },
      {
        "box": {
          "id": "js",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            220,
            620,
            22
          ],
          "text": "js formant_engine.js"
        }
      },
      {
        "box": {
          "id": "voice0",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            300,
            240,
            22
          ],
          "patcher": {
            "fileversion": 1,
            "appversion": {
              "major": 8,
              "minor": 6,
              "revision": 0,
              "architecture": "x64",
              "modernui": 1
            },
            "rect": [
              80,
              80,
              900,
              650
            ],
            "default_fontsize": 12.0,
            "default_fontname": "Arial",
            "boxes": [
              {
                "box": {
                  "id": "in",
                  "maxclass": "inlet",
                  "patching_rect": [
                    30,
                    30,
                    30,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "unpack",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    70,
                    690,
                    22
                  ],
                  "text": "unpack f f f f f f f f"
                }
              },
              {
                "box": {
                  "id": "saw",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    150,
                    95,
                    22
                  ],
                  "text": "saw~ 120"
                }
              },
              {
                "box": {
                  "id": "pack0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 300"
                }
              },
              {
                "box": {
                  "id": "q0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    275,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 80.0"
                }
              },
              {
                "box": {
                  "id": "filter0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.8 300 3.75"
                }
              },
              {
                "box": {
                  "id": "pack1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 870"
                }
              },
              {
                "box": {
                  "id": "q1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    490,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 100.0"
                }
              },
              {
                "box": {
                  "id": "filter1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.5 870 8.7"
                }
              },
              {
                "box": {
                  "id": "pack2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 2240"
                }
              },
              {
                "box": {
                  "id": "q2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    705,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 140.0"
                }
              },
              {
                "box": {
                  "id": "filter2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.3 2240 16.0"
                }
              },
              {
                "box": {
                  "id": "envpack",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    330,
                    110,
                    22
                  ],
                  "text": "pack 0. 20."
                }
              },
              {
                "box": {
                  "id": "env",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    375,
                    100,
                    22
                  ],
                  "text": "line~ 0."
                }
              },
              {
                "box": {
                  "id": "sum",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    330,
                    50,
                    22
                  ],
                  "text": "+~"
                }
              },
              {
                "box": {
                  "id": "sum2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    375,
                    50,
                    22
                  ],
                  "text": "+~"
                }
              },
              {
                "box": {
                  "id": "amp",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    425,
                    50,
                    22
                  ],
                  "text": "*~"
                }
              },
              {
                "box": {
                  "id": "out",
                  "maxclass": "outlet",
                  "patching_rect": [
                    310,
                    485,
                    30,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "desc",
                  "maxclass": "comment",
                  "patching_rect": [
                    30,
                    545,
                    750,
                    22
                  ],
                  "text": "Fixed excitation pitch; three parallel formants. Q = frequency / bandwidth."
                }
              },
              {
                "box": {
                  "id": "bwpack0",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    285,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline0",
                  "maxclass": "newobj",
                  "text": "line~ 80",
                  "patching_rect": [
                    285,
                    155,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwpack1",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    500,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline1",
                  "maxclass": "newobj",
                  "text": "line~ 100",
                  "patching_rect": [
                    500,
                    155,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwpack2",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    715,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline2",
                  "maxclass": "newobj",
                  "text": "line~ 140",
                  "patching_rect": [
                    715,
                    155,
                    100,
                    22
                  ]
                }
              }
            ],
            "lines": [
              {
                "patchline": {
                  "source": [
                    "in",
                    0
                  ],
                  "destination": [
                    "unpack",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    0
                  ],
                  "destination": [
                    "pack0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack0",
                    0
                  ],
                  "destination": [
                    "line0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line0",
                    0
                  ],
                  "destination": [
                    "q0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q0",
                    0
                  ],
                  "destination": [
                    "filter0",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line0",
                    0
                  ],
                  "destination": [
                    "filter0",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    1
                  ],
                  "destination": [
                    "pack1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack1",
                    0
                  ],
                  "destination": [
                    "line1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line1",
                    0
                  ],
                  "destination": [
                    "q1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q1",
                    0
                  ],
                  "destination": [
                    "filter1",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line1",
                    0
                  ],
                  "destination": [
                    "filter1",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    2
                  ],
                  "destination": [
                    "pack2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack2",
                    0
                  ],
                  "destination": [
                    "line2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line2",
                    0
                  ],
                  "destination": [
                    "q2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q2",
                    0
                  ],
                  "destination": [
                    "filter2",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line2",
                    0
                  ],
                  "destination": [
                    "filter2",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    4
                  ],
                  "destination": [
                    "envpack",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    3
                  ],
                  "destination": [
                    "envpack",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "envpack",
                    0
                  ],
                  "destination": [
                    "env",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter0",
                    0
                  ],
                  "destination": [
                    "sum",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter1",
                    0
                  ],
                  "destination": [
                    "sum",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "sum",
                    0
                  ],
                  "destination": [
                    "sum2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter2",
                    0
                  ],
                  "destination": [
                    "sum2",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "sum2",
                    0
                  ],
                  "destination": [
                    "amp",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "env",
                    0
                  ],
                  "destination": [
                    "amp",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "amp",
                    0
                  ],
                  "destination": [
                    "out",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    5
                  ],
                  "destination": [
                    "bwpack0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack0",
                    0
                  ],
                  "destination": [
                    "bwline0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline0",
                    0
                  ],
                  "destination": [
                    "q0",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    6
                  ],
                  "destination": [
                    "bwpack1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack1",
                    0
                  ],
                  "destination": [
                    "bwline1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline1",
                    0
                  ],
                  "destination": [
                    "q1",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    7
                  ],
                  "destination": [
                    "bwpack2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack2",
                    0
                  ],
                  "destination": [
                    "bwline2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline2",
                    0
                  ],
                  "destination": [
                    "q2",
                    1
                  ]
                }
              }
            ]
          },
          "text": "p voice0"
        }
      },
      {
        "box": {
          "id": "vlabel0",
          "maxclass": "comment",
          "patching_rect": [
            30,
            335,
            280,
            22
          ],
          "text": "A0: 120 Hz excitation / pan -0.6"
        }
      },
      {
        "box": {
          "id": "pan00",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            385,
            125,
            22
          ],
          "text": "*~ 0.951057"
        }
      },
      {
        "box": {
          "id": "pan01",
          "maxclass": "newobj",
          "patching_rect": [
            175,
            385,
            125,
            22
          ],
          "text": "*~ 0.309017"
        }
      },
      {
        "box": {
          "id": "voice1",
          "maxclass": "newobj",
          "patching_rect": [
            360,
            300,
            240,
            22
          ],
          "patcher": {
            "fileversion": 1,
            "appversion": {
              "major": 8,
              "minor": 6,
              "revision": 0,
              "architecture": "x64",
              "modernui": 1
            },
            "rect": [
              80,
              80,
              900,
              650
            ],
            "default_fontsize": 12.0,
            "default_fontname": "Arial",
            "boxes": [
              {
                "box": {
                  "id": "in",
                  "maxclass": "inlet",
                  "patching_rect": [
                    30,
                    30,
                    30,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "unpack",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    70,
                    690,
                    22
                  ],
                  "text": "unpack f f f f f f f f"
                }
              },
              {
                "box": {
                  "id": "saw",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    150,
                    95,
                    22
                  ],
                  "text": "saw~ 135"
                }
              },
              {
                "box": {
                  "id": "pack0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 300"
                }
              },
              {
                "box": {
                  "id": "q0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    275,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 80.0"
                }
              },
              {
                "box": {
                  "id": "filter0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.8 300 3.75"
                }
              },
              {
                "box": {
                  "id": "pack1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 870"
                }
              },
              {
                "box": {
                  "id": "q1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    490,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 100.0"
                }
              },
              {
                "box": {
                  "id": "filter1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.5 870 8.7"
                }
              },
              {
                "box": {
                  "id": "pack2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 2240"
                }
              },
              {
                "box": {
                  "id": "q2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    705,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 140.0"
                }
              },
              {
                "box": {
                  "id": "filter2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.3 2240 16.0"
                }
              },
              {
                "box": {
                  "id": "envpack",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    330,
                    110,
                    22
                  ],
                  "text": "pack 0. 20."
                }
              },
              {
                "box": {
                  "id": "env",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    375,
                    100,
                    22
                  ],
                  "text": "line~ 0."
                }
              },
              {
                "box": {
                  "id": "sum",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    330,
                    50,
                    22
                  ],
                  "text": "+~"
                }
              },
              {
                "box": {
                  "id": "sum2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    375,
                    50,
                    22
                  ],
                  "text": "+~"
                }
              },
              {
                "box": {
                  "id": "amp",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    425,
                    50,
                    22
                  ],
                  "text": "*~"
                }
              },
              {
                "box": {
                  "id": "out",
                  "maxclass": "outlet",
                  "patching_rect": [
                    310,
                    485,
                    30,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "desc",
                  "maxclass": "comment",
                  "patching_rect": [
                    30,
                    545,
                    750,
                    22
                  ],
                  "text": "Fixed excitation pitch; three parallel formants. Q = frequency / bandwidth."
                }
              },
              {
                "box": {
                  "id": "bwpack0",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    285,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline0",
                  "maxclass": "newobj",
                  "text": "line~ 80",
                  "patching_rect": [
                    285,
                    155,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwpack1",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    500,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline1",
                  "maxclass": "newobj",
                  "text": "line~ 100",
                  "patching_rect": [
                    500,
                    155,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwpack2",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    715,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline2",
                  "maxclass": "newobj",
                  "text": "line~ 140",
                  "patching_rect": [
                    715,
                    155,
                    100,
                    22
                  ]
                }
              }
            ],
            "lines": [
              {
                "patchline": {
                  "source": [
                    "in",
                    0
                  ],
                  "destination": [
                    "unpack",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    0
                  ],
                  "destination": [
                    "pack0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack0",
                    0
                  ],
                  "destination": [
                    "line0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line0",
                    0
                  ],
                  "destination": [
                    "q0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q0",
                    0
                  ],
                  "destination": [
                    "filter0",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line0",
                    0
                  ],
                  "destination": [
                    "filter0",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    1
                  ],
                  "destination": [
                    "pack1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack1",
                    0
                  ],
                  "destination": [
                    "line1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line1",
                    0
                  ],
                  "destination": [
                    "q1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q1",
                    0
                  ],
                  "destination": [
                    "filter1",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line1",
                    0
                  ],
                  "destination": [
                    "filter1",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    2
                  ],
                  "destination": [
                    "pack2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack2",
                    0
                  ],
                  "destination": [
                    "line2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line2",
                    0
                  ],
                  "destination": [
                    "q2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q2",
                    0
                  ],
                  "destination": [
                    "filter2",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line2",
                    0
                  ],
                  "destination": [
                    "filter2",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    4
                  ],
                  "destination": [
                    "envpack",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    3
                  ],
                  "destination": [
                    "envpack",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "envpack",
                    0
                  ],
                  "destination": [
                    "env",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter0",
                    0
                  ],
                  "destination": [
                    "sum",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter1",
                    0
                  ],
                  "destination": [
                    "sum",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "sum",
                    0
                  ],
                  "destination": [
                    "sum2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter2",
                    0
                  ],
                  "destination": [
                    "sum2",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "sum2",
                    0
                  ],
                  "destination": [
                    "amp",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "env",
                    0
                  ],
                  "destination": [
                    "amp",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "amp",
                    0
                  ],
                  "destination": [
                    "out",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    5
                  ],
                  "destination": [
                    "bwpack0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack0",
                    0
                  ],
                  "destination": [
                    "bwline0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline0",
                    0
                  ],
                  "destination": [
                    "q0",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    6
                  ],
                  "destination": [
                    "bwpack1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack1",
                    0
                  ],
                  "destination": [
                    "bwline1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline1",
                    0
                  ],
                  "destination": [
                    "q1",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    7
                  ],
                  "destination": [
                    "bwpack2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack2",
                    0
                  ],
                  "destination": [
                    "bwline2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline2",
                    0
                  ],
                  "destination": [
                    "q2",
                    1
                  ]
                }
              }
            ]
          },
          "text": "p voice1"
        }
      },
      {
        "box": {
          "id": "vlabel1",
          "maxclass": "comment",
          "patching_rect": [
            360,
            335,
            280,
            22
          ],
          "text": "A1: 135 Hz excitation / pan +0.6"
        }
      },
      {
        "box": {
          "id": "pan10",
          "maxclass": "newobj",
          "patching_rect": [
            360,
            385,
            125,
            22
          ],
          "text": "*~ 0.309017"
        }
      },
      {
        "box": {
          "id": "pan11",
          "maxclass": "newobj",
          "patching_rect": [
            505,
            385,
            125,
            22
          ],
          "text": "*~ 0.951057"
        }
      },
      {
        "box": {
          "id": "sum0",
          "maxclass": "newobj",
          "patching_rect": [
            110,
            445,
            50,
            22
          ],
          "text": "+~"
        }
      },
      {
        "box": {
          "id": "clip0",
          "maxclass": "newobj",
          "patching_rect": [
            110,
            490,
            150,
            22
          ],
          "text": "clip~ -0.95 0.95"
        }
      },
      {
        "box": {
          "id": "sum1",
          "maxclass": "newobj",
          "patching_rect": [
            410,
            445,
            50,
            22
          ],
          "text": "+~"
        }
      },
      {
        "box": {
          "id": "clip1",
          "maxclass": "newobj",
          "patching_rect": [
            410,
            490,
            150,
            22
          ],
          "text": "clip~ -0.95 0.95"
        }
      },
      {
        "box": {
          "id": "feedback",
          "maxclass": "newobj",
          "patching_rect": [
            730,
            300,
            240,
            22
          ],
          "text": "prepend /formants/feedback"
        }
      },
      {
        "box": {
          "id": "help",
          "maxclass": "comment",
          "patching_rect": [
            30,
            625,
            960,
            22
          ],
          "text": "Keep formant_engine.js beside this patch. No third-party Max externals required."
        }
      },
      {
        "box": {
          "id": "help2",
          "maxclass": "comment",
          "patching_rect": [
            30,
            650,
            1020,
            22
          ],
          "text": "Audio device: Max > Settings > Audio Status. Performance controls and formant display are in Processing."
        }
      },
      {
        "box": {
          "id": "input",
          "maxclass": "inlet",
          "patching_rect": [
            20,
            15,
            30,
            30
          ]
        }
      },
      {
        "box": {
          "id": "audio0",
          "maxclass": "outlet",
          "patching_rect": [
            20,
            740,
            30,
            30
          ]
        }
      },
      {
        "box": {
          "id": "audio1",
          "maxclass": "outlet",
          "patching_rect": [
            240,
            740,
            30,
            30
          ]
        }
      },
      {
        "box": {
          "id": "feedbackOut",
          "maxclass": "outlet",
          "patching_rect": [
            700,
            740,
            30,
            30
          ]
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "js",
            0
          ],
          "destination": [
            "voice0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "voice0",
            0
          ],
          "destination": [
            "pan00",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "voice0",
            0
          ],
          "destination": [
            "pan01",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            1
          ],
          "destination": [
            "voice1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "voice1",
            0
          ],
          "destination": [
            "pan10",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "voice1",
            0
          ],
          "destination": [
            "pan11",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pan00",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pan10",
            0
          ],
          "destination": [
            "sum0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum0",
            0
          ],
          "destination": [
            "clip0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pan01",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pan11",
            0
          ],
          "destination": [
            "sum1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum1",
            0
          ],
          "destination": [
            "clip1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "clip0",
            0
          ],
          "destination": [
            "audio0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "clip1",
            0
          ],
          "destination": [
            "audio1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            2
          ],
          "destination": [
            "feedback",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "feedback",
            0
          ],
          "destination": [
            "feedbackOut",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "input",
            0
          ],
          "destination": [
            "js",
            0
          ]
        }
      }
    ]
  }
}