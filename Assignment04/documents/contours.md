# CS 414 — Assignment 04: Contour Outlines

The outlines show **static (lexical) scope** and object lifetimes.

## (a)

```txt
Global
├─ f(y)  [function declaration]
└─ main(argc, argv)
    ├─ x = 2                        (local to main)
    └─ call f(x)
         └─ Frame f
            ├─ y = 2               (parameter)
            ├─ x = y + 1           (local to f; shadows main's x)
            └─ for (int i=0; i<3; i++)
               └─ Loop scope (per iteration)
                  ├─ i             (loop counter)
                  └─ { block }
                     ├─ temp = i*2 + x
                     └─ cout uses i, temp, x   (x is f’s x)
```

**Note:** After `f` returns, `main` prints its own `x` (2). The `x` inside `f` is a different variable.

---

## (b)

```txt
Global
└─ main()
   ├─ a = 5                         (outer a)
   ├─ ref_To_An_A  ──► a            (reference bound to outer a)
   └─ { inner block }
      ├─ a = 10                     (inner a shadows outer a)
      └─ cout << ref_To_An_A        (prints 5; ref still names outer a)
```

---

## (c)

```txt
Global
└─ main()
   ├─ p  ───►  [heap int 42]
   └─ { block }
      └─ q  ──┘                     (q points to the same heap object)
   └─ delete p                      (frees heap; q already out of scope)
```

---

## (d)

*(Given code matches (c), so the contour is the same.)*

```txt
Global
└─ main()
   ├─ p  ───►  [heap int 42]
   └─ { block }
      └─ q  ──┘
   └─ delete p
```

