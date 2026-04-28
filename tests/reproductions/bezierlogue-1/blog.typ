#import "/src/lib.typ": *

#let margin-note = marginnote
#let main-note(content) = {
    pad(left: 0.5em,
        block(width: 100%, {
            set text(size: 0.75em, font: "Gill Sans", style: "italic")
            set align(left)
            content
        })
    )
    v(0.5em)
}

#let debug-note(content) = {
    if sys.inputs.keys().contains("debug") {
        block(width: 100%, {
            set text(size: 0.75em, style: "italic", fill: rgb(0, 0, 255))
            set align(left)
            v(-0.4em)
            h(3em)
            content
        })
    }
}

#let nonumeq(eq) = math.equation(block: true, numbering: none, eq)
#show: tufte.with(
  title: "Cubic Bezier Fitting with Least Squares",
  author: "Jialin Lu",
  email: "luxxxlucy@gmail.com",
  date: "2025-04-30",
)

#debug-note[

The outline of the blog:

1. we start: intro of problem, notation and simple solution.
   bezier, we in particualr talk about cubic,
   notation and formuation, the t value and the point.
2. Simple least solving for solving P given T:
   given ordered points, fit a cubic bezier segment.
   we first use a heuristic to get the t values, and then we solve for P given T.
   then show the result. okay weird, it seems that it does recover the original curve!
3. Okay, this is because the t values obtained by heuristic are not good enough.
4. Introduce an alternating method:
   we can improve t based on p and we can improve p based on t.
   here we introduce the Pastva's method.
   how to improve p given t is already done, we now need a way to improve t given p.
   we then shwo two variants from Pastva:
   1. nearest point: find the nearest point on the curve for each point and use that as the new t.
   this is simple to implement but the convergence seems slow. Pastva also introduces a Gauss-Newton variant which as claimed should be faster
   2. Gauss-Newton: use the Jacobian matrix to update t.
   introduce it the math and then show result
   haha, it is not necessary better.
3. Ok let us thinkg about what went wrong, it seems that both nearest point and Gauss-Newton are really making very slight update each iteration. And each of the two steps are really making very tiny update each time.
   Can we do better? We note that the entire problem, although it is about t and p (linear to p and non linear to t)
   but it is in fact about T. We can actuall replace p by $p^*_t$ we thus can have a new objective function that is only about T.
   This is called the variable projection method.
4. Derive the formulation and show result
   haha, surprise, again it is not good, the update gradient w.r.t T is not just not easy to compute
5. Okay what now.
   given all these above, what we can do and what we learned?
   1. just rely one-shot T value estimation, and use the simple least square is not good
   2. but the chord length heuristic is surprisingly good, we are already in the good basin for convergence.
   3. alternating method is not good either, it is slow.
   4. we expected the variable projection method is good, but it is not.
   we learn that we should
   1. use simple, robust, stable method.
   2. math does not fulfill the promise
   3. instead of relying on unstable ones, really we use all that math to get an approximated graident and it might not work, instead we can rely on a simpler approximation of gradient we can use other small tricks such as linesearch and a little bit of stochasticity.
3. introduce new method: we get gradient from the simple gradient for t form gauss-newton but we can use the true T-only
   objective function to do linesearch and randomized perturbation to quickly converge.
   show result
]

#main-note[
  Note that this is the first blog in the *Bezielogue* series that I plan to write about curves. More fun to come!
]

#margin-note[
  code is available at #link("https://github.com/LuxxxLucy/bezier-rs")[luxxlucy/bezier-rs]
]

#emph[TL;DR] We introduce the basic task of fitting a cubic Bezier curve to an ordered list of points. We explore different approaches as follows:

1. Solving a linear least square as introduced in "Curve Fitting" and "Least Squares Bezier Fit".
#margin-note[
   #link("https://pomax.github.io/bezierinfo/#curvefitting")[Curve Fitting], Chapter 35 of The Bezier Primer
   
   #link("https://web.archive.org/web/20180403213813/http://jimherold.com/2012/04/20/least-squares-bezier-fit/")[Least Squares Bezier Fit], Jim Herold 2012
]
2. The vanilla method only optimizes the control points while fixing the parameter values. To improve, we can optimize both by an alternating two-stage method, iteratively improving control points and parameter values. This converges to the global minimum, but slowly.
#margin-note[
  Bezier Curve Fitting, Tim A Pastva 1998
]
3. We further utilize the relationship between control points and parameter values by variable projection. This eliminates the alternating steps and converts the problem into a single optimization over parameter values.
4. Lastly an ad-hoc improvisation is introduced. It is simpler and get faster convergence.

= Introduction <introduction>

#margin-note[
In most software applications, cubic Bezier segments are the canonical form: other types are often converted to cubic segments during preprocessing.
]
Given a list of points in 2D space, we want to fit a cubic Bezier curve to them. A cubic Bezier curve is defined by four control points $P = \{p_0, p_1, p_2, p_3\}$:
$
B_(P)(t) = (1-t)^3 p_0 + 3(1-t)^2 t p_1 + 3(1-t) t^2 p_2 + t^3 p_3
$ <cubic-bezier-curve>
#margin-note[
  The coefficients form the Bernstein basis functions, following Pascal's triangle:
  #nonumeq(
   align(center)[
     (1)  \
     (1, 1) \
     (1, 2, 1)  \
     (1, 3, 3, 1) \ 
     (1, 4, 6, 4, 1) \
     #sym.dots.h.c
   ]
  )
]
As shown in the figure below, a cubic Bezier curve consists of four control points:
#figure(
  image("./asset/cubic_bezier_curve.svg.png", width: 30%),
  caption: [A cubic Bezier curve with its control points and the influence of the parameter t
  (source: #link("https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Bezier_curve.svg/440px-Bezier_curve.svg.png")[wikipedia])]
)

where $P_0$ and $P_3$ are the on-curve endpoints, while $P_1$ and $P_2$ are the off-curve control points that influence the curve's shape. The parameter $t in [0, 1]$ is the domain range that kind of represents flow of time that traces the curve, with $t=0$ at the start and $t=1$ at the end.

= The Least Square Method <least-square-method>

Given a list of points $D = {d_1, d_2, ..., d_n}$ in a $2$-dimensional space, the cubic bezier curve which fits these points is the one that minimizes the following least square error:
$
min_(p_0, p_1, p_2, p_3) sum_(i=1)^n norm(B_(p_0, p_1, p_2, p_3)(t_i) - d_i)^2
$ <least-square-initial>
where $t_i$ is the parameter value for the $i$-th data point.

Now look at the @least-square-initial, we found that even though p_0, p_1, p_2, p_3 are the control points we are interested in,
$t_0, t_1, t_2, t_3$ are introduced as auxlilary variables that we need to estimate as well.

To simplify the formulation we denote $P = {p_0, p_1, p_2, p_3} $ and $T = {t_0, t_1, t_2, t_3}$ and $D = {d_1, d_2, ..., d_n}$ and rewrite the error function as:
$
min_(P,T) sum_(i=1)^n norm(B_P(t_i) - d_i)^2
$ <least-square-P-T>

= Level 1: least square, simply

A simple solution starts by estimating the t-values first, then solving the least squares problem for P. This works well because @least-square-P-T is linear with respect to P.
#margin-note[
  #link("https://web.archive.org/web/20180403213813/http://jimherold.com/2012/04/20/least-squares-bezier-fit/")[Least Squares Bezier Fit] Jim Herold, 2012

  #link("https://pomax.github.io/bezierinfo/#curvefitting")[The Bezier Primer] Chapter 35 Curve Fitting
]

The algorithm follows two simple steps:

1. Estimate $T$ using a heuristic
2. Solve for $P$ given $T$

For the first step, we can use several heuristics. Let's start with the chord length heuristic, which assigns t-values to points $d_0, d_1, ..., d_n$ based on their relative positions along the polyline connecting all data points. Specifically, for each data point, we assign a parameter t proportional to its distance along this polyline.

Once we have $T$, we can solve for $P$ that minimizes @least-square-P-T. Let's expand this using the Bezier curve equation from @cubic-bezier-curve:
#nonumeq(
  $
min_(P,T) sum_(i=1)^n norm(((1-t_i)^3 p_0 + 3(1-t_i)^2 t_i p_1 + 3(1-t_i) t_i^2 p_2 + t_i^3 p_3) - d_i)^2
  $
)

We can express this more compactly using matrix notation. First, note that:
#nonumeq(
$
B_P(t) = (1-t)^3 p_0 + 3(1-t)^2 t p_1 + 3(1-t) t^2 p_2 + t^3 p_3 \
= vec(1, t, t^2, t^3)^T mat(
  1;
  -3, 3;
  3, 6, 3;
  -1, 3, -3, 1;
) vec(p_0, p_1, p_2, p_3)
$
)

#let CT = $cal(T)_T$

We can now rewrite @least-square-P-T as:
$
min_(P,T) sum_(i=1)^n norm(B(t_i) p - d_i)^2 = min_(P, T) norm(CT B P - D)_F
$ <least-square-P-T-matrix-form>

where $norm(.)_F$ is the Frobenius norm, $CT$ is the matrix of t-values raised to powers, $B$ is the Bernstein matrix, $P$ contains our control points, and $D$ contains our data points.

#nonumeq(
$
CT = mat(
  1, t_0, t_0^2, t_0^3;
  1, t_1, t_1^2, t_1^3;
  ...,...,...,...;
  1, t_n, t_n^2, t_n^3;
)
$
)
#margin-note[
  The polynomials $CT$ are trivially derived from $T$.
]

#nonumeq(
$
B = 
mat(
  1;
  -3, 3;
  3, 6, 3;
  -1, 3, -3, 1;
)
$
)
#margin-note[
  Also known as the Bernstein matrix
]

#nonumeq(
$
P = vec(p_0, p_1, p_2, p_3)
$)
#margin-note[
  $P$ represents the control points of the cubic Bezier curve, which are our variables of interest.
]

#nonumeq(
$
D = vec(d_1, d_2, ..., d_n)
$
)
#margin-note[
  The sampled data points. Note that each $d_i$ is actually a 2D point, but we've simplified the notation here for clarity.
]

Solving @least-square-P-T-matrix-form given $T$ reduces to a standard linear least squares problem. Let $L(P,T)$ be the objective in @least-square-P-T-matrix-form:
#nonumeq(
$ 
L(P,T) = norm(CT B P - D)_F = (CT B P - D)^T (CT B P - D)
$
)

#nonumeq(
$
diff(L(P,T))/diff(P) = -2CT^T (D - CT B P)
$
)

Since $L(P,T)$ is linear with respect to $P$, we can find the minimum by setting its derivative to zero. For simplicity, let's denote $A = CT B$. Then we have:
$
P^* = (A^T A)^(-1) A^T D "where" A = CT B
$ <least-square-P-given-T>

where $(A^T A)^(-1) A^T$ is the pseudo-inverse of $A = CT B$. Computing @least-square-P-given-T is efficient and straightforward.

Now let us test this visually. We first generate a ground truth curve and then sample points from it, we then apply the least square method to fit the curve.

#figure(
  image("./asset/sanity_check_default_least_square_fitting.svg", width: 60%),
  caption: [Comparison of Original and Fitted Curves]
)

Unfortunately the results seem off, suggesting that curve fitting does not recover the original curve, not even close.

  Notice how the fitted curve passes through all sample points but has a significantly different shape from the original curve.

  In fact, the fitting process does not guarantee that the fitted curve will pass through all sample points. This is just a coincidentally good case where the points were sampled at uniform t values.

We further run the algorithm with different heuristics for t-values:

1. Uniform: evenly distribute t values from 0 to 1, without considering the actual point values
2. Chord length: the default method, which approximates arc length
3. Centripetal: square root of chord length, another good approximation

The results are shown below:

#figure(
  grid(
    columns: 2,
    gutter: 1em,
    // First row: original and samples
    [#image("./asset/comparison/original.svg", width: 100%)
     #text(size: 0.9em)[Original cubic Bezier curve]],
    [#image("./asset/comparison/samples.svg", width: 100%)
     #text(size: 0.9em)[Sample points used for fitting]],
    
    // Second row: all fitted curves
    [#image("./asset/comparison/fitted_Uniform.svg", width: 100%)
     #text(size: 0.9em)[Fitted curve using Uniform parameterization]],
    [#image("./asset/comparison/fitted_ChordLength.svg", width: 100%)
     #text(size: 0.9em)[Fitted curve using ChordLength parameterization]],
    [#image("./asset/comparison/fitted_Centripetal.svg", width: 100%)
     #text(size: 0.9em)[Fitted curve using Centripetal parameterization]],
    [#image("./asset/comparison/fitted_ground_truth.svg", width: 100%)
     #text(size: 0.9em)[Fitted curve using ground truth t-values]],
    
  ),
  caption: [Comparison of Original and Fitted Curves]
)

#figure(
  image("./asset/comparison/combined.svg", width: 60%),
  caption: [Combined visualization of all methods]
)

If we had the ground truth t-values, we for sure could recover the original curve perfectly. But heuristics would always be non-perfect. This then becomes too rigid - we need more flexibility. We should be able to adjust the t-values as well instead of relying on heuristics once and for all.

= Level 2: An Alternating Method

Now we want to move a step forward. Let us also optimize $T$ as well. We here introduce an alternating method based on Pastva Tim's thesis.
#margin-note[
  Bezier Curve Fitting, Tim A Pastva 1998
]

The alternating method is an iterative method that alternates between estimating $T$ and $P$:

1. Get initial $T$
2. Find $P$ given $T$
3. Update $T$ given $P$
4. Repeat steps 2 and 3 until convergence

We will first use the chord length heuristic as default to get the initial $T$ and then use that to fit $P$. Step 2 is essentially @least-square-P-given-T, so I will not repeat here.

Step 3 updates $T$ based on $P$. Let us start with something simple. Update $T$ given $P$ can be done simply by updating $T$ by the nearest point on the curve.

For each $d_i in D$, find $t$ that minimizes $norm(B_P(t) - d_i)_2$. Although we can solve this by solving a (quartic) equation, for simplicity and robustness we can just opt for a binary search.

#figure(
  image("./asset/nearest_point.svg", width: 60%),
  caption: [Nearest point]
)

We can see it converges (the result from 0 to 10 iteration steps is plotted below). But we can also see that the convergence is just too slow.

#figure(
  image("./asset/convergence_alternating.svg", width: 60%),
  caption: [Convergence of the alternating method]
)

Pastva considers this nearest point method as the first variant. It also talks about another variant that uses Gauss-Newton method to update $T$ directly.

Notice that @least-square-P-T-matrix-form is in fact a non-linear optimization problem w.r.t $T$. Gauss-Newton tries to solve this by approximating a good `gradient` for $T$ and updating it iteratively. Specifically:

We first define the loss function aka residual vector as:
#nonumeq(
$
R = mat(
  B_x(t_1) - x_1;
  B_y(t_1) - y_1;
  B_x(t_2) - x_2;
  B_y(t_2) - y_2;
  #sym.dots.v ;
  B_x(t_n) - x_n;
  B_y(t_n) - y_n;
) = mat(r_1; r_2; ...; r_n) ∈ ℝ^2n
$
)
where each $r_i = mat(B_x(t_i)-x_i; B_y(t_i)-y_i)$.

We then have the Jacobian matrix of partial derivatives:
#nonumeq(
$
J = diff(R)/diff(t) = mat(
  diff(B_x(t_1))/diff(t_1), 0,            ...,         0;
  diff(B_y(t_1))/diff(t_1), 0,            ...,         0;
  0,            diff(B_x(t_2))/diff(t_2), ...,         0;
  0,            diff(B_y(t_2))/diff(t_2), ...,         0;
  #sym.dots.v,  #sym.dots.v,              #sym.dots.v, #sym.dots.v ;
  0,            0,                        ...,         diff(B_x(t_n))/diff(t_n);
  0,            0,                        ...,         diff(B_y(t_n))/diff(t_n);
) ∈ ℝ^(2n×n)
$
)
note that
#nonumeq(
$
   mat(
    diff(B_x(t))/diff(t) ;
    diff(B_y(t))/diff(t) ;
   )
   = diff(B(t))/diff(t) = [0, 1, 2t, 3t^2] B P
   = [0, 1, 2t, 3t^2] B vec(
     P_x,
     P_y
   )
$
)
The Jacobian matrix is in fact block diagonal if we consider a $vec(diff(B_x(t_i))/diff(t_i), diff(B_y(t_i))/diff(t_i))$ for each $t_i$ as a unit.

Given the residual vector and the jacobian, Gauss-Newton method tries to find the step vector that minimizes the residual by a linear approximation of $R$ as $R + J Delta t$.
#margin-note[
  Namely, under the first order Taylor expansion, $R(t) #sym.tilde.equiv R + J Delta t$
]
#nonumeq(
 $
 min_(t) norm(R)_F #sym.tilde.equiv min_(Delta t) norm(R + J Delta t)_F
 $
)
Finding the best step vector corresponds to solving the derivative to 0,
#nonumeq(
$
diff(norm(R + J Delta t)_F)/diff(Delta t) =
J^T R + J^T J Delta t = 0
$
)
and thus
#nonumeq(
$
Delta t = -(J^T J)^(-1) J^T R
$
)

After we get the step vector $Delta t$, we update each $t_i$:
#nonumeq(
$
t_i^(k+1) = t_i^(k) + Delta t_i = t_i^(k) - [(J^T J)^(-1) J^T R]_i
$
)

#margin-note[
  Needless to say that we need to ensure it stays in $[0,1]$:
  $t_i <- "clamp"(t_i, 0, 1)$
]

While this approach appears promising, my experimental results show that Gauss-Newton's performance is comparable to the nearest point method. Across different ground truth curves and sampling patterns, the convergence rate improvement is negligible. Given its simplicity and stability, I think the nearest point method is preferred.

#figure(
  image("./asset/convergence_plot_pastva.png", width: 60%),
  caption: [Convergence of the Gauss-Newton method compared to nearest point. (x-axis: iteration steps, y-axis: error) It seems the improvement is slightly small even negligible. We denote the nearest point as Pastva variant 1 and Gauss-Newton as Pastva variant 2.]
)

= Level 3: Variable Projection

The alternating method converges quite slowly. One hypothesis is that this is because each step is really small and thus the improvement of each iteration becomes negligible, more so if it reaches vicinity of the solution.

Maybe a non-alternating method should be better? Now I consider a further advanced method called variable projection.
#main-note[
  #link("https://www.cs.umd.edu/users/oleary/software/varpro.pdf")[Variable Projection for Nonlinear Least Squares Problems], Dianne O'Leary and Bert Rust 2007

  #link("https://core.ac.uk/download/pdf/36730496.pdf")[Total least squares fitting of Bézier and B-spline curves to ordered data], Borges and Pastva 2002

  #link("https://geo-ant.github.io/blog/2020/variable-projection-part-1-fundamentals/")[The Variable Projection Method - Nonlinear Least Squares Fitting], 2020 Geo-Ant
]

The idea of variable projection is that if we look closely enough, we will find that even though we have $P$ and $T$ in the objective function, $P$ is actually determined by $T$.

Observe that the objective function in @least-square-P-T is linear to $P$, so we can just solve for $P$ given $T$ and then plug it into @least-square-P-T. Given:

#nonumeq(
$
P^*_T = (A^T A)^(-1) A^T D = ((CT B)^T (CT B) )^(-1) (CT B)^T D
$
)

We insert $P^*$ back into the objective function of @least-square-P-T-matrix-form and denote $A_T = CT B$. The objective is:

$
min_(P,T) sum_(i=1)^n norm(B(t_i) p - d_i)^2\
= min_(P,T) norm(CT B P - D)_F \
= min_(P, T) norm(A_T P - D)_F \
= min_(T) norm(A_T P^*_T - D)_F 
$ <total-loss-function-variable-projection>

$T$ becomes the only variable that we will optimize over. Similarly, let us optimize this non-linear problem over $T$ with Gauss-Newton.

#margin-note[
  expand $A_T = CT B$ would lead to
#nonumeq(
$ min_(T) norm(CT B (((CT B)^T (CT B) )^(-1) (CT B)^T D) - D)_F $
)
but I think this is just too verbose and not easy to understand. I will keep using the compact notation $A_T = CT B$.
]

The residual $R$ is defined as $R = A_T P^*_T - D$ and the Jacobian matrix of partial derivatives is:

#let PA = $A_T P^*_T$
   #nonumeq(
   $
   J = diff(R)/diff(t) = mat(
     diff(PA)/diff(t_1), 0,            ...,         0;
     diff(PA)/diff(t_1), 0,            ...,         0;
     0,            diff(PA)/diff(t_2), ...,         0;
     0,            diff(PA)/diff(t_2), ...,         0;
     #sym.dots.v,  #sym.dots.v,              #sym.dots.v, #sym.dots.v ;
     0,            0,                        ...,         diff(PA)/diff(t_n);
     0,            0,                        ...,         diff(PA)/diff(t_n);
   ) ∈ ℝ^(2n×n)
   $
   )

For each entry in $J$, we have
#nonumeq(
$
diff(PA)/diff(t) \
= diff(A_T P^*_T)/diff(t) \
= diff(A_T (A_T^T A_T)^(-1) A_T^T)/diff(t)
$
)
$
= diff(A_T)/diff(t) (A_T^T A_T)^(-1) A_T^T D + A_T diff((A_T^T A_T)^(-1))/diff(t) A_T^T D + A_T (A_T^T A_T)^(-1) diff(A_T^T)/diff(t) D
$ <variable-projection-jacobian>

This all seems good, but after I implemented and made some experiments with it I found that this is numerically very unstable. Especially when we want to get the second term, in particular:
#nonumeq(
$
diff((A_T^T A_T)^(-1))/diff(t)
= - (A_T^T A_T)^(-1) diff(A_T^T A_T)/diff(t) (A_T^T A_T)^(-1) \
= - (A_T^T A_T)^(-1) ( diff(A_T^T)/diff(t) A_T + A_T^T diff(A_T)/diff(t) ) (A_T^T A_T)^(-1)
$
)

and so the second term of @variable-projection-jacobian when expanded becomes
#nonumeq(
$
- A_T (A_T^T A_T)^(-1) diff(A_T^T A_T)/diff(t) (A_T^T A_T)^(-1) A_T^T D \
= - CT B ((CT B)^T CT B)^(-1) 
( diff (B^T CT^T)/diff(t) CT B + B^T CT^T diff(CT B)/diff(t) )
(CT B)^(-1) CT B D
$
)

This unfortunately requires a very careful implementation and my attempts result in a very numerically unstable state.

If we really want to make it work, I would probably need to revise a careful implementation and add a lot of check routines as well as doing line search to determine a step size. This becomes ridiculously complicated and not really practical.

#margin-note[
  Let me be honest, it is probably because of my poor math skills, I have never been good at it. So either the implementation is not careful enough, or maybe my derivation is not correct.
]

= Level 4: A Weak Variable Projection Method

Okay, so I am stuck. I spent some time and effort on variable projection, hoping that this could do some help, but this seems to be an unfruitful path.

How about now we look in retrospect? We do know:

1. Chord length heuristic is actually a good heuristic, so good that assuming we have the right ordered data sample points, we are already in the good basin.
2. An alternating approach is good actually, but converges super slow.
3. Even in the alternating approach, using the simpler nearest point is equally good, and considering robustness, better than Gauss-Newton.
4. Advanced method like variable projection is just a juggling of unnecessary complexity and we have not been able to reach a good solution.

Okay, so what now? Getting a correct $Delta t$ for minimizing @total-loss-function-variable-projection is hard, but we do have a good $Delta t$ for @least-square-P-T-matrix-form. It surely is suboptimal, but it is good enough. We just need some tweaks to make it work to converge faster.

We can make up for the suboptimal step update with a line search that is based on a zero-order evaluation of @total-loss-function-variable-projection:

1. First, we obtain the search direction $Delta t$ from the Gauss-Newton method on @least-square-P-T-matrix-form:
#nonumeq(
$
Delta t = -(J^T J)^(-1) J^T R
$
)
where $R$ is the residual from @least-square-P-T-matrix-form.

2. We perform a line search along this direction to find an optimal step size $alpha$, evaluated using @total-loss-function-variable-projection instead of @least-square-P-T-matrix-form:
#nonumeq(
$
min_(alpha) norm(A_(T + alpha Delta t) P^*_(T + alpha Delta t) - D)_F
$
)
We determine $alpha$ using line search (golden section search).

3. Finally, we enhance robustness by sampling randomly around $T+alpha Delta t$ and selecting one that minimizes @total-loss-function-variable-projection.


The key insight is that while computing the true gradient of the total loss function is numerically unstable, we can:
- Use the simpler loss function to obtain a search direction
- Validate steps using the total loss function through line search
- Improve robustness through random sampling


Results:

#margin-note[
  The following plot can be generated by running this command in the repository:
  ```
  cargo run --bin bezier-least-square-fit-convergence-comparison-plot                              
  ```
]

#figure(
  image("./asset/convergence_plot_all.png", width: 60%),
  caption: [Convergence of new weak variable projection method compared to other ones. The method shows better convergence than both Pastva variants. (x-axis: iteration steps, y-axis: error)]
)

#margin-note[
  Of course it would be good, that is more heuristic and so much more steps of compute!
]

== Lessons Learned

Recently I have seen a re-occurring theme happening in different places and it is that
sometimes we should prefer simple methods just for the sake of simplicity, and simplicity sometimes correlates with robustness.
