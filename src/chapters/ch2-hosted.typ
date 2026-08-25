#import "../preamble.typ": conflict, minor, unit, qty, qtyrange, num, eqn, eqref, symbol-table, chapter-setup, AR
#show: chapter-setup

= A Unified Approach to Aerodynamic Stability

#table(
      columns: (1fr, 2fr),
      align: horizon,
      stroke: none,
      // inset: (x: 8pt, y: 3pt),
      table.hline(),
      table.header(
        table.cell()[Symbol],
        table.cell()[Meaning]
      ),
      table.hline(stroke: 0.5pt),
      [$A$], [initial amplitude],
      [$A$, $B$, $C$], [space axes],
      [$A$, $B$, $C$, $D$], [roots of quartic equation used to determine angular frequencies of pitch and yaw in cases of rolling rockets],
      [$A'$, $B'$, $C'$], [roots of cubic equation used to determine angular pitch and yaw frequencies of a rolling rocket undergoing force-free precession],
      [$A_f$], [amplitude of sinusoidal forcing],
      [$A_r$], [amplitude of response to sinusoidal forcing],
      [$A_1$], [initial amplitude of first mode of critically damped or overdamped motion; _also_ initial amplitude of first mode of roll-coupled motion],
      [$A_2$], [initial amplitude of second mode of critically damped or overdamped motion; _also_ initial amplitude of second mode of roll-coupled motion],
      [$A R$], [amplitude ratio],
      [$A R_c$], [amplitude ratio of roll-coupled motion],
      [$A R_(c r e s)$], [resonant amplitude ratio of roll-coupled motion],
      [$A R_(r e s)$], [resonant amplitude ratio],
      [$AR$], [aspect ratio],
      [$C_N_alpha$], [normal force coefficient],
      [$(C_N_alpha)_B$], [normal force coefficient of boattail],
      [$(C_N_alpha)_n$], [normal force coefficient of nose],
      [$(C_N_alpha)_S$], [normal force coefficient of shoulder],
      [$(C_N_alpha)_T$], [normal force coefficient of tailfin assembly],
      [$(C_N_alpha)_T(B)$], [normal force coefficient of tailfin assembly in the presence of the body],
      [$(C_N_alpha)_1$], [normal force coefficient of one fin],
      [$C_1$], [corrective moment coefficient],
      [$C_2$], [damping moment coeffient],
      [$C_(2A)$], [aerodynamic damping moment coefficient],
      [$C_(2R)$], [propulsive damping moment coefficient],
      [$D$], [inverse time constant],
      [$D$, $E$, $F$], [body axes],
      [$D_1$], [inverse time constant of first mode in roll-coupled motion],
      [$D_2$], [inverse time constant of second mode in roll-coupled motion],
      [$F$], [thrust],
      [$arrow(F)$], [force],
      [$F(alpha_x)$], [function of pitch angle],
      [$cal(F)$], [abbreviated notation for a function of the dynamic parameters used in writing the angular frequencies of roll-coupled motion],
      [$G(Omega_x)$], [function of pitch angular velocity],
      [$H$], [strength of impulse],
      [$I$], [moment of inertia],
      [$I_D$], [moment of inertia about $D$ axis],
      [$I_E$], [moment of inertia about $E$ axis],
      [$I_F$], [moment of inertia about $F$ axis],
      [$I_L$], [longitudinal moment of inertia],
      [$I_(L c h)$], [longitudinal moment of inertia of a hollow cylindrical component],
      [$I_(L c s)$], [longitudinal moment of inertia of a solid cylindrical component],
      [$I_(L o)$], [longitudinal moment of inertia of any object],
      [$I_(L o) '$], [longitudinal moment of inertia of any object about its own center of gravity],
      [$I_R$], [radial moment of inertia],
      [$I_(R c h)$], [radial moment of inertia of a hollow cylinder],
      [$I_(R c s)$], [radial moment of inertia of a solid cylinder],
      [$I_(R f)$], [radial moment of inertia of a single fin],
      [$I_(R n)$], [radial moment of inertia of the nose],
      [$I_(R t)$], [radial moment of inertia of a complete set of fins],
      [$I_s$], [moment of inertia of reference standard],
      [$K$], [particular response to step forcing],
      [$K_(T(B))$], [tail-body interference coefficient],
      [$L$], [length],
      [$L_(n e)$], [distance of nozzle exit from tip to nose],
      [$M$], [moment, torque; _also_ mass of any component],
      [$M_D$], [moment about $D$ axis],
      [$M_E$], [moment about $E$ axis],
      [$M_F$], [moment about $F$ axis],
      [$M_b$], [mass of boattail],
      [$M_c$], [corrective moment; _also_ mass of cylinder],
      [$M_d$], [damping moment],
      [$M_e$], [mass of engine],
      [$M_f$], [mass of the fins as used in computing C.G. location; _also_ mass of one fin as used in computing $I_(R f)$],
      [$M_n$], [mass of nose],
      [$M_o$], [mass of any object],
      [$M_p$], [mass of payload section including contents],
      [$M_r$], [mass of rigged and packed recovery system],
      [$M_s$], [step moment; _also_ mass of shoulder],
      [$M_t$], [mass of body tube],
      [$M_x$], [moment about $x$ axis],
      [$M_y$], [moment about $y$ axis],
      [$M_z$], [moment about $z$ axis],
      [$N$], [normal force; _also_ number of fins],
      [$R$], [radius],
      [$R_i$], [inner radius],
      [$R_o$], [outer radius],
      [$T_L$], [period of torsional oscillation of a rocket suspended on a torsion wire with its longitudinal axis horizontal],
      [$T_R$], [period of torsional oscillation of a rocket suspended on a torsion wire with its longitudinal axis vertical],
      [$T_s$], [period of torsional oscillation of reference standard],
      [$V$], [airspeed],
      [$V_e$], [exhaust velocity],
      [$overline(W)$], [longitudinal position of complete vehicle C.G.],
      [$overline(W)_b$], [longitudinal position of boattail C.G.],
      [$overline(W)_c$], [longitudinal position of C.G. of a cylindrical component],
      [$overline(W)_e$], [longitudinal position of engine C.G.],
      [$overline(W)_f$], [longitudinal position of fin C.G.],
      [$overline(W)_n$], [longitudinal position of nose C.G.],
      [$overline(W)_o$], [longitudinal position of the C.G. of any object],
      [$overline(W)_p$], [longitudinal position of payload section C.G.],
      [$overline(W)_r$], [longitudinal position of recovery system C.G.],
      [$overline(W)_s$], [longitudinal position of shoulder C.G.],
      [$overline(W)_t$], [longitudinal position of body tube C.G.],
      [$X$, $Y$, $Z$], [intermediate axes; _also_ abbreviations for functions of the dynamic parameters used in analysis of roll-coupled motion],
      [$overline(Y)_T$], [radial position of C.P. of a single fin],
      [$overline(Z)$], [longitudinal position of complete vehicle C.P.],
      [$overline(Z)_(C B)$], [longitudinal position of conical boattail C.P.],
      [$overline(Z)_(C S)$], [longitudinal position of conical shoulder C.P.],
      [$overline(Z)_n$], [longitudinal position of nose C.P.],
      [$overline(Z)_T$], [longitudinal position of tailfin C.P.],
      [$a$], [dummy variable used in analysis of roll-coupled motion],
      [$arrow(a)$], [linear acceleration],
      [$b$], [y-intercept of a straight line; _also_ dummy variable used in analysis of roll-coupled motion],
      [$c_r$], [fin chord at root],
      [$c_t$], [fin chord at tip],
      [$(dif (quad))/(dif t)$], [derivative of $(quad)$ with respect to time],
      [$(dif^2 (quad))/(dif t^2)$], [second derivative of $(quad)$ with respect to time],
      [$e$], [base of the Napierian logarithm system, numerically equal to approximately 2.718],
      [$f_x (t)$], [pitch forcing function],
      [$f_y (t)$], [yaw forcing function],
      [$k_d$], [roll damping interference coefficient],
      [$k_r$], [roll forcing interference coefficient],
      [$m$], [mass; _also_ constant of proportionality in the equation of a straight line],
      [$dot(m)$], [mass expulsion rate],
      [$m_p$], [mass of propellant],
      [$n$], [peak number],
      [$r_r$], [reference radius],
      [$r_t$], [radius of body section to which the fins are joined],
      [$s$], [span of one fin, root to tip],
      [$t$], [time],
      [$t_b$], [burning time of rocket engine],
      [$t_m$], [time at which maximum angle of attack occurs],
      [$t_"max"$], [time of occurrence of maximum overshoot angle],
      [$x$], [independent variable],
      [$x_t$], [longitudinal distance from leading edge of fin root to leading edge of fin tip],
      [$y$], [dependent variable],
      [$Gamma_c$], [mid-chord sweep angle],
      [$Omega_X$], [angular velocity component about $X$ axis],
      [$Omega_X_0$], [yaw angular velocity at $t=0$],
      [$Omega_Y$], [angular velocity component about $Y$ axis],
      [$Omega_Y_0$], [pitch angular velocity at $t=0$],
      [$Omega_Z$], [angular velocity component about $Z$ axis],
      [$alpha$], [angular displacement, angle of attack],
      [$alpha_D$], [angular displacement (Euler's angle) about $D$ axis],
      [$alpha_E$], [angular displacement (Euler's angle) about $E$ axis],
      [$alpha_F$], [angular displacement (Euler's angle) about $F$ axis],
      [$alpha_x$], [yaw angle],
      [$alpha_(x m)$], [maximum yaw angle],
      [$alpha_x_0$], [yaw angle at $t=0$],
      [$alpha_y$], [pitch angle],
      [$alpha_y_0$], [pitch angle at $t=0$],
      [$alpha_0$], [initial angle of attack],
      [$alpha_1$], [maximum overshoot angle],
      [$beta$], [frequency ratio],
      [$beta_c$], [coupled frequency ratio],
      [$beta_(c "res")$], [resonant coupled frequency ratio],
      [$beta_"res"$], [resonant frequency ratio],
      [$gamma$], [angular acceleration],
      [$zeta$], [damping ratio],
      [$zeta_c$], [coupled damping ratio],
      [$theta$], [angle of fin cant],
      [$lambda$], [$c_t/c_r$ ratio],
      [$rho$], [mass density of the atmosphere],
      [$tau$], [ratio $(s+r_t)/r_t$],
      [$tau_1$], [time constant of first mode of overdamped motion],
      [$tau_2$], [time constant of second mode of overdamped motion],
      [$phi$], [phase angle],
      [$phi_1$], [phase angle of first mode of roll-coupled motion],
      [$phi_2$], [phase angle of second mode of roll-coupled motion],
      [$omega$], [angular velocity; _also_ angular frequency of oscillatory response],
      [$omega_D$], [component of angular velocity about $D$ axis],
      [$omega_E$], [component of angular velocity about $E$ axis],
      [$omega_F$], [component of angular velocity about $F$ axis],
      [$omega_c$], [critical angular frequency],
      [$omega_(c "res")$], [resonant coupled angular frequency],
      [$omega_f$], [angular frequency of sinusoidal forcing],
      [$omega_n$], [natural frequency],
      [$omega_(n c)$], [coupled natural frequency],
      [$omega_"res"$], [resonant frequency],
      [$omega_z$], [roll rate],
      [$omega_1$], [angular frequency of first mode of roll-coupled motion],
      [$omega_2$], [angular frequency of second mode of roll-coupled motion],
      [$abs((quad))$], [absolute value of $(quad)$],
      table.hline()
    )

// === page 11 ===
== Introduction <sec:2-0>

Model rocketeers have been familiar with the concept of aerodynamic stability for quite some time.
As early as 1958 G. Harry Stine had published simplified treatments of aerodynamic stability as it pertains to model rocket design, in which the hobbyist was first made aware of the existence of a center of pressure (C.P.) and of the all-important relationship between it and the model's center of gravity (C.G.).
In these early treatments the center of pressure was approximated by the center of lateral area, and for the next eight years the "cardboard cutout" method remained the standard model builder's technique for estimating the location of the C.P.

The next major advance in the field came in 1966 at the Eighth National Association of Rocketry Annual Meet, where James Barrowman of the National Aeronautics and Space Administration's Sounding Rocket Branch unveiled an algebraic method based on the theory of potential flow capable of determining the center of pressure of a model rocket flying subsonically and at small angles of attack to a high order of accuracy.
Barrowman showed that the actual C.P. of a model rocket lies some distance aft of the location predicted by the cutout method, and that therefore model rocketeers had been designing their vehicles too conservatively.
// === page 12 ===
All consideration of model rocket stability had thus far been confined exclusively to its static manifestations, with the nature of the C.P.-C.G. relationship being used to determine whether a rocket, once deflected from facing directly into the relative airstream, would experience a moment tending to return it to the undeflected state (in which case it would be considered stable) or one tending to further deflect it (in which case it would be considered unstable).
Little attention had been paid to the details of the process by which a stable rocket, once disturbed in its flight, restores itself to alignment with its intended flight path, or to the process by which an unstable rocket goes head over heels (unless, strangely enough, it is spinning rapidly enough about its centerline).
The _statics_ of stability had been treated in admirable detail, but its _dynamics_ remained virtually ignored.

This is not to say that our hobby had had _no_ exposure to stability considered in a dynamic context.
Luther W. Gurkin of the National Aeronautics and Space Administration's Wallops Station had presented an excellent short treatment of rocket dynamics to the contestants at the Sixth National Association of Rocketry Annual Meet in 1964.
Although copies of Gurkin's "Basic Missile Aerodynamic Stability" were distributed to a number of interested persons at the meet, however, little was done to apply his results specifically to model rockets for nearly four years.
Our vehicles continued to be subject to puzzling anomalies of behavior that could not be satisfactorily explained by considerations of static stability alone.
Sometimes they "weathercocked" --- flew directly into the prevailing wind
// === page 13 ===
at launch.
In other cases they would mysteriously tip to some random orientation at launch and subsequently fly straight and true.
Some models would oscillate excessively on the way up; others hardly at all, and still others would experience a sort of "semi-instability" in which the nose circled violently about the intended axis of flight.

This writer began to investigate the problem of dynamic stability early in 1968, working from a general consideration of the dynamical equations governing the rotational motions of a streamlined projectile about its center of gravity during free flight.
Although the mathematical details of such an approach are sometimes formidable, I felt that the greatest amount of information could only be obtained from the most general analysis.
In this section I am going to endeavor to present the results of this analysis and to apply them to model rockets by the use of the Barrowman equations, concluding with some suggestions which should help the model rocketeer formulate designs which will both fly stably and exhibit favorable dynamic behavior.

The dynamical equations describing the behavior we are interested in are necessarily of a type called _differential_ equations, and as such require the techniques of calculus for their solution.
I want to emphasize as strongly as I can, however, that it is _not necessary_ that the reader understand calculus in order to follow the presentation.
To the engineer, calculus is fundamentally a tool that enables him to obtain _algebraic_ equations describing the behavior of the system he is investigating.
Care has therefore been taken to emphasize the
// === page 14 ===
_algebraic results_ of calculus-dependent derivations, with the calculus operations being considered as formulae for altering differential equations to algebraic equations.
No reader who has had his second year of high school algebra, and perhaps some exposure to analytic geometry, should have any difficulty in understanding the text.

As the exact forms of the equations governing the rotational motions of projectiles subject to aerodynamic moments are quite complex and introduce fundamental mathematical barriers to our obtaining physical solutions, I have made a number of approximations in order to cast the equations into a more readily soluble form.
Approximations of the kind made here are quite common in the solution of the differential equations encountered in all branches of mathematical physics.
Called _linearizations_, they involve physical and/or geometrical reasoning by which the investigator can neglect or modify certain of the characteristics of his mathematics in ways not immediately determinable or obvious from the mathematics itself.
I have taken care to identify each such approximation and to give its physical justification in order to keep the treatment as basic as possible.

Certain portions of this analysis parallel Luther Gurkin's "Basic Missile Aerodynamic Stability", while others use information contained in James Barrowman's "Calculating the Center of Pressure of a Rocket", a National Aeronautics and Space Administration Educational Services Office pamphlet embodying the algebraic results of his analysis.
In order to facilitate correlation of this treatment with theirs, appropriate references have been included.
// === page 15 ===
== The Dynamical Equations <sec:2-1>

=== Euler's Angles <sec:2-1.1>

Suppose we have a rocket which has been rotated about some set of mutually perpendicular axes fixed in space: $A$, $B$, and $C$.
We can speak of this rotational displacement in a quantitative way if we consider a second set of axes, $D$, $E$, and $F$, to have been fixed in the rocket, with origin at the rocket's C.G., and with directions coincident with $A$, $B$, and $C$ before the rotation began, and to have _remained_ fixed in the rocket as it rotated.
We can always uniquely determine the final orientation of the rocket if we agree to abide by the following rule: that, in undergoing any given rotation, the rocket first _yaws_ through an angle $alpha_D$ about axis $D$; then _pitches_ through an angle $alpha_E$ about axis $E$; and finally _rolls_ through an angle $alpha_F$ about axis $F$.
This process is illustrated in @fig:2-1.

The _body axes_ $D$, $E$, and $F$ first rotate about $D$ through angle $alpha_D$.
Throughout this first rotation $D$ coincides with axis $A$ of the _space axes_ and $E$ and $F$ remain in the plane defined by $B$ and $C$.
At its completion axis $F$ coincides with the dashed line _Of_ and axis $E$ with _Oe_.
Next the body axes rotate about the _new position_ of $E$ (that is, about _Oe_) through an angle $alpha_E$.
This rotation occurs in the plane of $A$ and _Of_, and at its conclusion axis $F$ is in its final position as shown and axis $D$ lies along line _Od_.
$E$, of course, is still along _Oe_.
Finally the body axes execute the roll through angle $alpha_F$ about $F$, in the plane defined by _Oe_ and _Od_, bringing all the axes into their final positions.

It is important that this order of rotations be observed;
// === page 16 ===
#figure(
  image("/assets/figures-original/fig2-1.png"),
  caption: [A set of Euler's angles for specifying the rotational position of a model rocket. $alpha_D$ is the angle of yaw, $alpha_E$ is the angle of pitch, and $alpha_F$ is the angle of roll. The origin of the coordinate system is taken as the center of gravity of the rocket.]
) <fig:2-1>
// === page 17 ===
if the order in which the yaw, pitch, and roll occur is changed the final position of the rocket will be different.
A mathematician would say that angular displacements, or rotations, are _not vector quantities_ because, although they specify both a magnitude and a direction, they do not _commute in addition_.
The three "locating angles" $alpha_D$, $alpha_E$, and $alpha_F$ for specifying the rotational displacement of a solid body are called a _set of Euler's angles_ after their discoverer, the Swiss mathematician and physicist Leonhard Euler (1707-1783).
You can see that if for any reason we wish to postulate an _intermediate_ set of axes which will perform some, but not all, of the movements of the rocket, we can find the rocket's final position by determining _first_ the position of the intermediate axes with respect to the space axes, and _then_ the position of the body axes with respect to the intermediate axes.
At this point such a procedure seems a meaningless complication, but it will be very useful later on.

=== Angular Velocity <sec:2-1.2>

If you imagine the Euler's angles of a certain rotation becoming very small, so that the rocket is barely turned from its original position, you may notice a curious and very useful fact: the order of the angular displacements is no longer of such great importance.
If, when the angles were large, the rocket was considered to first pitch, then yaw, and finally roll or to perform the rotations in _any_ order other than the prescribed one of yaw, pitch, roll, we obtained a different final orientation in each case.
Now, however, the effect of such alterations in the order of rotations is very slight;
// === page 18 ===
nearly the same result is obtained no matter what the order in which the rotations occur.
If the rotations are allowed to become _infinitesimally_ small, so that they are, in the terminology of calculus, _differential quantities_, the equality becomes exact.
Thus, differential rotations are vector quantities; they possess both a magnitude (though slight, to be sure) and a direction, and they do commute in addition.
Differentials are denoted by a lower-case letter $d$ in front of the quantity in question; differential angular displacements are thus $d alpha_D$, $d alpha_E$, and $d alpha_F$.

Now suppose the rocket is turning continuously, so that its Euler's angles keep changing as time goes on.
This can be represented mathematically by stating that, in every _differential element_ of time $d t$, the rocket experiences differential angular displacements $d alpha_D$, $d alpha_E$, and $d alpha_F$.
We then form the fractions

#eqn("1")[
  $ omega_D &= (d alpha_D)/(d t) \
    omega_E &= (d alpha_E)/(d t) \
    omega_F &= (d alpha_F)/(d t) $
] <eq:2-1>

and define $omega_D$ = angular velocity about $D$, or $D$-component of angular velocity

$omega_E$ = angular velocity about $E$, or $E$-component of angular velocity

$omega_F$ = angular velocity about $F$, or $F$-component of angular velocity

Angular velocity is called the _derivative with respect to time_ of angular displacement, or the _time rate of change_ of angular displacement.
Angular velocities are vector quantities: they
// === page 19 ===
have both magnitude and sign, they do commute in addition, and all vector operations such as cross product, dot product, and coordinate transformation apply to them.
Specifically, we represent them in a so-called right-handed coordinate system as _positive_ about a given axis when they cause a rotation such that a screw with right-handed threads would advance along that axis in the positive direction, _negative_ when such a progression would be in the negative direction.
A right-handed system itself, such as our $A$, $B$, $C$ axis set, is established by the requirement that the right-handed screw turned about its axis from $A$ toward $B$ advance positively along $C$.
This convention is illustrated in @fig:2-2, while @fig:2-3 shows a rocket undergoing a rotation in which all components of angular velocity are positive.
An angular velocity is conveniently represented by an arrow along the axis about which it occurs, of direction determined by the sign of the component, and of length proportional to its magnitude.
This allows all the common vector operations to be performed.
@fig:2-4 shows this convention in operation.

It is now necessary to go back and pick up a few loose ends in order to introduce some concepts which will be useful later on.
First, there is the matter of defining positive and negative rotations; this must be done to obtain physically meaningful results from any investigation of rocket motion even though angular displacements do not have all the properties required of vectors.
This is accomplished directly by the analogy of the right-handed screw through replacing the "turning direction" of the screw with the angular displacement.
Secondly, the derivative relationship of angular velocity to angular displacement needs
// === page 20 ===
#figure(
  image("/assets/figures-original/fig2-2.png"),
  caption: [Definition of a right-handed coordinate system. Turning a screw with right-hand threads as if axis $A$ were being turned toward axis $B$ causes the screw to advance positively along axis $C$.]
) <fig:2-2>

#figure(
  image("/assets/figures-original/fig2-3.png"),
  caption: [Positive components of angular velocity. $omega_D$ is a positive _yaw rate_, $omega_E$ is a positive _pitch rate_, and $omega_F$ is a positive _roll rate_.]
) <fig:2-3>
// === page 21 ===
#figure(
  image("/assets/figures-original/fig2-4.png"),
  caption: [Vector representation of positive angular velocity components. Compare with Figures 2 and 3 to see how this representation is suggested by the direction of advance of a right-handed screw.]
) <fig:2-4>
// === page 22 ===
a little more explanation.
While physical reasoning using differential quantities leads directly to the general form of equations Eq. #eqref(<eq:2-1>), this technique is not very useful when the question is: "given the angular displacement as a function of time (that is, in an analytical formula), compute the angular velocity".
In this case the relation

$! omega = (d alpha)/(d t) $

is taken to mean: "given $alpha(t)$ (the meaning of this notation is "$alpha$ as a function of time" and it is read "$alpha$ of $t$"), apply a known rule, or formula, for _differentiating it_ with respect to time and obtain $omega(t)$".
The expression, or formula, for $alpha(t)$ is subject to certain restrictions for this method to work properly, but these need not concern you in anything discussed here.
I am going to _list the formulae_ for the derivatives needed in this treatment wherever they appear, so that it will not be necessary to know them in order to follow the discussion.

=== Applied Moments, Angular Accelerations, and Moment of Inertia <sec:2-1.3>

Moment, or torque, is to rotational motion as force is to linear motion.
It is the cause of all changes in the state of the rotational motion of a physical body.
The simplest kind of relation between an applied moment and the resulting angular motion is identical in form to Newton's second law of motion for translational displacement: $arrow(F) = m arrow(a)$.
To see this consider a flywheel, initially at rest, mounted in an axle held in frictionless bearings.
At some time arbitrarily designated as $t = 0$ we begin to apply a constant moment about the shaft.
// === page 23 ===
An angular velocity will then arise which starts from zero and increases linearly (i.e., at a constant rate) with time.
The rate is directly proportional to the applied moment and inversely proportional to a property of the mass distribution in the wheel called its _moment of inertia_ about its axis of radial symmetry.
The relationship between an applied moment and the resulting _angular acceleration_ is written

#eqn("2")[$ M = I gamma $] <eq:2-2>

where $M$ = applied moment

$I$ = moment of inertia

$gamma$ = angular acceleration

Note that the angular acceleration $gamma$ is the time rate of change of the angular velocity $omega$, just as $omega$ is the time rate of change of the angular displacement $alpha$.
This sequence of derivative relationships is written

#eqn("3")[
  $ gamma &= (d omega)/(d t) \
           &= (d)/(d t) ((d alpha)/(d t)) \
           &= (d^2 alpha)/(d t^2) $
] <eq:2-3>

where the expression $d^2 alpha/d t^2$ is read, "the second derivative of $alpha$ with respect to $t$".
From a practical standpoint it means that the rule for differentiating $alpha(t)$ has been applied twice in succession in order to obtain $gamma(t)$.
Thus $gamma$, $omega$, and $alpha$ are all related by derivatives with respect to time, a property of great value to analysis.
In the case of a constant applied moment, for instance, the angular acceleration is given by

$! gamma = M/I $
// === page 24 ===
while any mathematician could tell you that the angular velocity is

$! omega = M/I t $

and the angular displacement after a time $t$ is

$! alpha = M/(2 I) t^2 $

These relations are illustrated in Figure 5.
Note also that both moment and angular acceleration are vectors, while moment of inertia, like mass, is a scalar.
Moment of inertia gets its name not from the fact that an object exerts an equal and opposite moment on the cause of its angular acceleration (although it does), but from the fact that it is, mathematically speaking, the "second moment" of mass about a given axis, a term arising from the calculus formula for $I$.
This analysis will not present the _integral form_ that must be used to calculate $I$ for the most general case, but the results for a few particular objects will appear later in the treatment.

=== Euler's Dynamical Equations <sec:2-1.4>

The general three-dimensional angular motion of rigid bodies in response to general applied moments is far more complicated than the simple flywheel example given above.
Their derivation is of no interest to model rocketeers, and I have therefore omitted it entirely from this presentation.
The results of interest to us are the dynamical equations for a body which has sufficient symmetry for the directions of the so-called _principal axes_ to be geometrically obvious, and which is free to rotate about its center of mass in any direction.
These equations, for a body with principal body axes $D$, $E$, $F$, rotating with respect to axes $A$, $B$, $C$ fixed in space, are

// === page 25 ===
#figure(
  image("/assets/figures-original/fig2-5.png"),
  caption: [Angular acceleration of a flywheel. At time $t = 0$ a constant moment $M$ is applied to a flywheel whose moment of inertia about the axis is $I$, producing an angular acceleration $gamma = M/I$.]
) <fig:2-5>
// === page 26 ===
#eqn("4")[
  $
  M_D &= I_D (dif omega_D)/(dif t) - (I_E - I_F) omega_E omega_F \
  M_E &= I_E (dif omega_E)/(dif t) - (I_F - I_D) omega_F omega_D \
  M_F &= I_F (dif omega_F)/(dif t) - (I_D - I_E) omega_D omega_E
  $
] <eq:2-4>

where $M_D$, $M_E$, and $M_F$ are moments about $D$, $E$, and $F$ impressed by external agencies and $I_D$, $I_E$, and $I_F$ are the moments of inertia taken about axes $D$, $E$, and $F$ respectively.
These equations, also due to Euler, were a landmark in the history of classical dynamics and are named Euler's dynamical equations in his honor.
For bodies having trigonal or greater mass _symmetry_ about the longitudinal axis (this category includes most rockets) we have

$! I_D = I_E equiv I_L $

$! I_F equiv I_R $

and the equations reduce to

#eqn("5")[
  $
  M_D &= I_L (dif omega_D)/(dif t) - (I_L - I_R) omega_E omega_F \
  M_E &= I_L (dif omega_E)/(dif t) - (I_R - I_L) omega_F omega_D \
  M_F &= I_R (dif omega_F)/(dif t)
  $
] <eq:2-5>

It will become clear in a little while that these forms of the Euler equations are a bit inconvenient to use.
It will be preferable to construct an intermediate system of axes $X$, $Y$, and $Z$ which follow the rocket in yaw and pitch, but do not roll.
Thus, $Z$ always coincides with $F$ but $X$ and $Y$ do not coincide with $D$ and $E$
// === page 27 ===
unless $alpha_F = 0$.
Therefore,

$! alpha_x = alpha_D $

$! alpha_y = alpha_E $

$! alpha_z = 0 != alpha_F $

This set of axes is shown in @fig:2-6.
Since the rocket is symmetrical about $Z$, the intermediate axes remain principal regardless of the roll angle $alpha_F$.
Let the angular velocity components of the intermediate axes be denoted by $Omega_X$, $Omega_Y$, and $Omega_Z$.
Then we have

$! Omega_X = omega_D $

$! Omega_Y = omega_E $

$! Omega_Z = 0 != omega_F $

Since the $Z$ axis always coincides with the $F$ axis, the notation can be simplified to include only three coordinate variables by writing

$! omega_z = omega_F $

but we must be careful not to confuse $omega_z$ (the roll rate of the rocket) with $Omega_Z$ (the roll rate of the intermediate coordinates, which is kept zero).
The dynamical equations now become, for a body with trigonal or greater mass symmetry about $Z$,

#eqn("6")[
  $
  M_X &= I_L (dif Omega_X)/(dif t) + I_R Omega_Y omega_z \
  M_Y &= I_L (dif Omega_Y)/(dif t) - I_R Omega_X omega_z \
  M_z &= I_R (dif omega_z)/(dif t)
  $
] <eq:2-6>
// === page 28 ===
#figure(
  image("/assets/figures-original/fig2-6.png"),
  caption: [Space axes, intermediate axes, and body axes. The space axes ($A$, $B$, $C$) are rotationally fixed with respect to inertial space. The body axes ($D$, $E$, $F$) are fixed in the airframe of the rocket and follow it in yaw, pitch, and roll, while the intermediate axes ($X$, $Y$, $Z$) follow the rocket in yaw and pitch but maintain a zero roll angle.]
) <fig:2-6>
// === page 29 ===
== The Linearized Theory <sec:2-2>

=== Corrective and Damping Moment <sec:2-2.1>

In considering the dynamics of a free-flying, fin-stabilized ballistic missile we are dealing principally with applied moments due to aerodynamic forces.
Suppose that you have a model rocket which you have launched vertically, for instance.
The model has begun its flight straight and true, but has subsequently been disturbed in some unknown manner such that it is rotated about its $X$ axis.
What happens next?

$Omega_Y$ and $omega_z$ are both zero, and there is no $M_Y$ or $M_z$ involved.
The dynamical equations thus reduce to

$! M_X = I_L (dif Omega_X)/(dif t) $

Now if the rocket is statically stable a _corrective moment_ $M_c$ will be generated, of _sign_ opposite to the displacement.
Due to center of pressure travel, separation, and interference effects the precise dependence of corrective moment on angular displacement is quite complicated analytically.
It is observed that the functional form of this relation is similar in appearance to @fig:2-7.
As the rocket develops an angular velocity in response to the corrective moment, a _damping moment_ $M_d$ will also arise due to the consequent additional component of the relative velocity of the airstream normal (that is, perpendicular) to the longitudinal axis of the rocket.
This moment will be opposite in sign to the _angular velocity_ and has a functional form roughly as shown in @fig:2-8.

Suppose we denote $M_c$ as an unspecified function of angular
// === page 30 ===
#figure(
  image("/assets/figures-original/fig2-7.png"),
  caption: [Variation of corrective moment with angular deflection for a typical model rocket at constant airspeed.]
) <fig:2-7>

#figure(
  image("/assets/figures-original/fig2-8.png"),
  caption: [Variation of damping moment with angular velocity for a typical model rocket at constant airspeed.]
) <fig:2-8>
// === page 31 ===
displacement by writing $M_c = F(alpha_x)$ and $M_d$ as an unspecified function of angular velocity by writing $M_d = G(Omega_X)$.
Then we can write

$!
M_X &equiv M_X " due to " alpha_x + M_X " due to " (dif alpha_x)/(dif t) \
&= -M_c - M_d \
&= -F(alpha_x) - G(Omega_X)
$

Substituting these expressions in the dynamical equations, we have

$! I_L (dif Omega_X)/(dif t) = -F(alpha_x) - G(Omega_X) $

or

#eqn("7")[
  $
  I_L (dif^2 alpha_x)/(dif t^2) + F(alpha_x) + G((dif alpha_x)/(dif t)) = 0
  $
] <eq:2-7>

An equation of this kind is called a _homogeneous_, _nonlinear_, _differential_ equation --- "differential" because derivatives of $alpha_x$ are involved; "homogeneous" because, when every term depending on $alpha_x$ or its derivatives is moved to the left side of the equal sign, the right side of the equation is zero; and "nonlinear" because functions which may not be of the form "$y = m x + b$" (the equation of a straight line) may be involved in relating corrective moment to angular displacement and damping moment to angular velocity.
The "nonlinear" part is of particular importance: it means that, in general, the equation cannot be solved by any known means; it means that we have no assurance that a _solution even exists_, and, if it does, that there may not be more than one.
It even means that the assumption that $M_c$ and
// === page 32 ===
$M_d$ could simply be added to obtain $M_X$ was incorrect.

=== The Linearization Approximations <sec:2-2.2>

In order to obtain a closed-form mathematical solution to the dynamical equations it is necessary to adopt a number of _linearization approximations_.
The reasoning behind these proceeds as follows: although the functions representing $M_c$ and $M_d$ are not of the form "$y = m x + b$", they may be approximated by such forms over limited ranges of the values of their independent variables.
An approximation of this kind is the _tangent line_ to the exact function at some point of interest.
Since the motions of a statically-stable rocket will all occur about $alpha = 0$, $dif alpha/dif t = 0$, and $dif^2 alpha/dif t^2 = 0$, zero is our tangent-point for these approximations.
The linearization approximation for corrective moment states that

#eqn("8")[
  $
  M_c approx [(dif M_c)/(dif alpha_x)]_(alpha_x = 0) alpha_x equiv C_1 alpha_x
  $
] <eq:2-8>

which is read: "$M_c$ is approximately equal to $alpha_x$ times its derivative with respect to $alpha_x$ at $alpha_x = 0$".
Similarly, the linearized damping moment is written

#eqn("9")[
  $
  M_d approx [(dif M_d)/(dif Omega_X)]_(Omega_X = 0) Omega_X equiv C_2 Omega_X
  $
] <eq:2-9>

The linearization procedure is illustrated in @fig:2-9.
You can see that the approximations are just the _slopes_ of the moment curves at $alpha_x$ and $Omega_X = 0$, respectively, multiplied by $alpha_x$ and $Omega_X$, respectively.
Another physical interpretation of the concept of the derivative is thus to view it as the local
// === page 33 ===
#figure(
  image("/assets/figures-original/fig2-9.png"),
  caption: [Linearization approximations used to determine corrective moment coefficient and damping moment coefficient for the model rocket of Figures 7 and 8. The corrective moment can be considered linearly proportional to the yaw deflection $alpha_x$ for yaw angles less than 0.225 radian, while the damping moment can be considered linearly proportional to the yaw rate for yaw rates below 87 rad/sec.]
) <fig:2-9>
// === page 34 ===
_slope_ of the graphical representation of the function whose derivative is being taken.

The linearized moment coefficients of this treatment are identical to those given in the Gurkin report.
The correspondence between the two is as follows:

_ Present Treatment _

$! [(dif M_c)/(dif alpha_x)]_(alpha_x = 0) equiv C_1 $

$! [(dif M_d)/(dif Omega_X)]_(Omega_X = 0) equiv C_2 $

_ Gurkin Report _

$! [(dif M_c)/(dif alpha_x)]_(alpha_x = 0) equiv M_alpha $

$! [(dif M_d)/(dif Omega_X)]_(Omega_X = 0) equiv M_(dot(phi)) $

Within the ranges of validity of the linearization approximations it is permissible to express the total applied moment about the $X$ axis as

$! M_X = -C_1 alpha_x - C_2 (dif alpha_x)/(dif t) $

These approximations are valid for $alpha_x$ and $dif alpha_x/dif t$ sufficiently _small_; this means that the theory is restricted to cases of relatively small angular displacements and angular velocities; it is a so-called small-perturbation theory.
This restriction is acceptable in statically stable rockets for two reasons: in the vast majority of cases, the yaw and pitch disturbances encountered during flight _will_ be sufficiently small for a valid linear description and the angular velocities involved will _not_ be out of the linear range of $M_d$.
Secondly, should nonlinear behavior _be_ encountered the description of the linear theory will still be _qualitatively_ correct and, in any case, the motion will eventually damp down to within the linear displacement dependence range.
Furthermore, should you ever obtain from this
// === page 35 ===
theory a solution indicating continued large and violent motions (for which the theory itself is invalid), you will have, in a sense, obtained all the information you need: you will know that the rocket in question ought to be redesigned.

The limiting numerical values of yaw and pitch that can be treated within this theory are about 12 degrees (about 0.2 radian) either side of zero.
The maximum permissible angular velocity will vary with the length of the rocket in question, the placement of its fins, and the speed at which it is travelling.
As a practical matter, the inertial and aerodynamic characteristics of a well-designed rocket will invariably satisfy the angular velocity limit for that rocket.

The great advantage of using the intermediate axis system now becomes clear: the angular displacements of the rocket about the $X$ and $Y$ axes will generally be small perturbations, but since there is no restoring moment about the roll axis of a ballistic rocket the angular displacements about the $Z$ axis will often _not_ be small.
The intermediate axes remove the necessity of keeping track of the third Euler's angle $alpha_F$ and result in considerable analytical simplification.
They allow us to view the motions in yaw and pitch from a position fixed in roll, without having to rotate with the rocket whenever it spins about its longitudinal axis.
We can thus observe the yawing and pitching motions from a perspective relative to the space axes that is constant within the linear theory and can compute them directly as deviations of the longitudinal axis from the direction of flight.
// === page 36 ===
Returning to the dynamical equation for our case of yaw displacement and substituting the linearized form of the applied moment $M_X$, we find that

#eqn("10")[
  $
  I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x = 0
  $
] <eq:2-10>

This is now a homogeneous _linear_ differential equation with _constant coefficients_.
It is known that such equations _always_ have a solution and that the solution is _unique_ (i.e., that there is only one).
Furthermore, the functional _form_ of the solution to this particular equation is well known and the solution itself is readily obtainable by a substitution technique called the _method of undetermined coefficients_.
If the rocket under consideration has four identical fins, the equation describing the pitching motion will be precisely analogous to that describing the yawing motion, the two having the same linear moment coefficients:

$! I_L (dif^2 alpha_y)/(dif t^2) + C_2 (dif alpha_y)/(dif t) + C_1 alpha_y = 0 $

The pitch and yaw linear moment coefficients of a three-finned rocket may be expected to be slightly different and there will be some slight aerodynamic rolling moments arising from pitch and yaw angular displacements and angular velocities.
Reasoning from the observed flight behavior of such rockets, though, it appears that these effects are slight and we shall restrict ourselves here to considering pitching behavior with the same constants as yawing behavior, both being aerodynamically decoupled from roll.
// === page 37 ===
=== Coupled and Decoupled Systems of Equations <sec:2-2.3>

Once the linearization approximations have been made the dynamical equations of a rocket which is not rolling about its centerline become

#eqn("11")[
  $
  I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x &= 0 \
  I_L (dif^2 alpha_y)/(dif t^2) + C_2 (dif alpha_y)/(dif t) + C_1 alpha_y &= 0
  $
] <eq:2-11>

For cases in which the rocket is spinning with some roll rate $omega_z$ we have

#eqn("12")[
  $
  I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x + I_R omega_z (dif alpha_y)/(dif t) &= 0 \
  I_L (dif^2 alpha_y)/(dif t^2) + C_2 (dif alpha_y)/(dif t) + C_1 alpha_y - I_R omega_z (dif alpha_x)/(dif t) &= 0
  $
] <eq:2-12>

Equations (11) are said to be _decoupled_ because $alpha_x$ and its time derivatives do not appear in the same equation with $alpha_y$ and its time derivatives.
Equations (12), however, have been _coupled_ together by the presence of the terms due to $omega_z$.
Each equation of a decoupled system of equations can be solved independently of any others, but coupled systems must be solved simultaneously (i.e., by using various mathematical techniques to combine them so that they can both be considered at once).
In both systems, if the roll rate $omega_z$ is constant, the third dynamical equation is identically zero and I have not written it down.
It is important to notice that, in a radially symmetrical body like a rocket, _pitch_ can be coupled to _yaw_ by the _presence_ of roll but roll itself is never inertially coupled either to pitch or to yaw.
// === page 38 ===
=== Homogeneous, Particular, and Steady-State Solutions <sec:2-2.4>

Recall that we began our discussion of the linearization approximations with an example in which we considered a rocket which had been initially displaced and concerned ourselves with its subsequent return to alignment.
The only moments applied to the rocket were those due to the angular deflection itself and its time derivatives.
Motions of this kind are called _homogeneous_, _force-free_, or _characteristic_ responses.
The state of the rocket at the time the observation of its behavior begins is known as the _set of initial conditions_; these must be known in order to obtain a complete solution to the motion.
Both the initial angular deflection and the initial angular velocity must be specified to complete the set.

Now suppose that there are _additional_ moments acting on the rocket, and that these moments are functions of time due to causes other than angular displacement and its time derivatives.
They might, for instance, be due to aerodynamic imbalances such as drag on the launch lug, misaligned fins, or the movement of control surfaces on the fins.
They might also be due to off-center engine mounting, angled thrust, or the momentary expulsion of solid residue from the rocket nozzle.
Such moments are called _inputs_, or _forcing functions_, and they appear on the right-hand side of the dynamical equations, which are therefore no longer homogeneous.
For the case of zero roll rate with forcing in yaw and pitch we have

#eqn("13")[
  $
  I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x &= f_x(t) \
  I_L (dif^2 alpha_y)/(dif t^2) + C_2 (dif alpha_y)/(dif t) + C_1 alpha_y &= f_y(t)
  $
] <eq:2-13>

// === page 39 ===
where $f_x(t)$ is read, "function of time, about the X-axis" and $f_y(t)$ is read, "function of time, about the Y-axis".
With the presence of a constant roll rate the equations become

#eqn("14")[$
  I_L frac(dif^2 alpha_x, dif t^2) + C_2 frac(dif alpha_x, dif t) + C_1 alpha_x + I_R omega_z frac(dif alpha_y, dif t) &= f_x(t) \
  I_L frac(dif^2 alpha_y, dif t^2) + C_2 frac(dif alpha_y, dif t) + C_1 alpha_y - I_R omega_z frac(dif alpha_x, dif t) &= f_y(t)
$] <eq:2-14>

The response of the rocket to these moments is the sum of the characteristic motion and a motion called the _particular response_ which is directly attributable to the effect of the forcing.
The initial angular positions and velocities in yaw and pitch must be specified, as before, to obtain the complete motion; in this case, however, it is the _sum_ of the characteristic and particular responses which must satisfy the initial conditions.
For a rocket flying straight and evenly upward before encountering a disturbance, these conditions are zero.
From this you can see how the initial conditions of the characteristic motion arise: the rocket, initially undisturbed, is subjected to a forcing function which arises, persists for some interval of time, and then dies away to zero again.
After the forcing has passed the rocket possesses some angular displacement and velocity --- the initial conditions of the characteristic response, which then ensues.
As will be shown later, the characteristic response of a statically stable rocket decreases with time and finally becomes effectively zero.
Thus after some time the condition of straight and true flight is restored.

Both the linearity of the dynamical equations and the decaying behavior of the characteristic response are extremely
// === page 40 ===
valuable features of the motion from the standpoint of analysis.
Linear differential equations possess the property of _superposition_, meaning that the response to any number of inputs applied simultaneously is just the _sum_ of the particular responses due to each one separately, plus the homogeneous response.
The effect of each disturbance can be computed separately and the total effect found by summing the individual effects.
This is certainly far easier than solving an equation with one huge right-hand side!
And since the characteristic response approaches zero with time, any forcing function which continues for a long enough time will cause the complete solution to approach the particular solution alone: after enough time has passed, the particular response is all that remains.
You will thus see references in the literature of dynamics to the _steady-state_, or _forced_, response to this type of input, the term being most often applied when the input is specifically a smooth, periodic function of time such as a sine wave.

== Solutions to the Dynamical Equations for Particular Cases of Interest <sec:2-3>

Having given the reader some background from which to proceed, I am going to compute the properties of some solutions to the dynamical equations which are of particular interest to the model rocketeer.
The presentation will be divided into two parts: one which will treat rockets having a _zero_ roll rate and a second which will consider the behavior of models _spinning_ about their centerlines.
Each section will consider the four basic dynamic responses: homogeneous, step, impulse, and steady-state sinusoidal.
It can be shown mathematically that there is
// === page 41 ===
no response that cannot be synthesized by adding together various combinations of these, so that by investigating the "basic four" a designer can obtain all the information he will ever need about the dynamic characteristics of his rocket.

I wish to emphasize here that you should _not_ become concerned if you find it difficult to follow the detailed course of each calculation.
You will _not_ have to _know_ how to solve the differential equations in order to design model rockets properly, and the mathematical derivations have been presented solely for the interest of those readers desiring a rigorous treatment.
What you _should try_ to concentrate on are the algebraic solutions obtained in each case, for it is from these that the response to _any_ disturbance can be directly computed and it is on them that the dynamical characteristics of any given model rocket depend.

=== Dynamical Behavior at Zero Roll Rate <sec:2-3.1>

==== Generalized Homogeneous Response <sec:2-3.1.1>

The homogeneous response for generalized initial conditions describes the motion executed by a rocket in response to some transient disturbance which has since died away.
Since there is no roll coupling only one of the equations (11) need be solved.
The other, which is similar, will have an analogous solution for its own initial conditions.
Suppose that, throughout this section, we adopt the convention that the rocket is considered to have been disturbed in yaw alone.
In each of the four decoupled problems the pitching behavior is precisely analogous to the yawing behavior; an analysis of pitching motion can add nothing to the information already obtained from an analysis of yawing motion
// === page 42 ===
and I have therefore omitted it.
All you need remember on this score is that everything I say about yaw applies also to pitch.

The equation to be solved for the characteristic yaw response is

$! I_L frac(dif^2 alpha_x, dif t^2) + C_2 frac(dif alpha_x, dif t) + C_1 alpha_x = 0 $

Over a certain range of relative values of $I_L$, $C_1$ and $C_2$ the solution is known to be of the form

#eqn("15")[$ alpha_x = A e^(-D t) sin(omega t + phi) $] <eq:2-15>

where $e$ is the base of the _Naperian_, or _natural_ logarithm system and is numerically equal to about 2.718.
$t$ denotes time and $A$, $D$, $omega$ and $phi$ are constants to be determined.
By "time" I mean the time elapsed since the observation of the dynamic response has begun, not the time elapsed since the rocket was launched.
To reference Eq. #eqref(<eq:2-15>) to liftoff, call the time elapsed since launch $t'$ and the time interval between launch and the beginning of the observation $t'_0$.
Then replace $t$ in formula (15) by the quantity $(t'-t'_0)$.
$A$ is called the _initial amplitude_, $D$ is defined as the _inverse time constant_, $omega$ (not literally an angular velocity of the rocket's motion) is the _angular frequency_ in radians/second (for time reckoned in seconds), and $phi$ is the _phase angle_, or simply "phase", in radians.
A _radian_, the fundamental natural unit of angle measure, is approximately equal to 57.3 degrees.
The formulae for the time derivatives of the function described by Eq. #eqref(<eq:2-15>) are:
// === page 43 ===
$!
  frac(dif alpha_x, dif t) &= -A D e^(-D t) sin(omega t + phi) + A omega e^(-D t) cos(omega t + phi) \
  frac(dif^2 alpha_x, dif t^2) &= A(D^2 - omega^2)e^(-D t) sin(omega t + phi) - 2 A omega D e^(-D t) cos(omega t + phi)
$

Substituting these relations in the yaw equation gives

$!
  I_L A(D^2 - omega^2)e^(-D t) sin(omega t + phi)
  - 2 I_L A omega D e^(-D t) cos(omega t + phi)
  - C_2 A D e^(-D t) sin(omega t + phi)
  + C_2 A omega e^(-D t) cos(omega t + phi)
  + C_1 A e^(-D t) sin(omega t + phi)
  = 0
$

Since $A e^(-D t)$ is nonzero and appears in every term, we can divide by it and obtain

$!
  I_L(D^2 - omega^2)sin(omega t + phi)
  - 2 I_L omega D cos(omega t + phi)
  - C_2 D sin(omega t + phi)
  + C_2 omega cos(omega t + phi)
  + C_1 sin(omega t + phi)
  = 0
$

Since sine and cosine vary differently with time the only way in which a function involving both can be zero for _all_ time is for the sine and cosine terms to sum independently to zero:

$!
  I_L(D^2 - omega^2)sin(omega t + phi) - C_2 D sin(omega t + phi) + C_1 sin(omega t + phi) &= 0 \
  -2 I_L omega D cos(omega t + phi) + C_2 omega cos(omega t + phi) &= 0
$

Dividing the first of these by $sin(omega t+phi)$, the second by $omega cos(omega t+phi)$, we obtain

$!
  I_L(D^2 - omega^2) - C_2 D + C_1 &= 0 \
  -2 I_L D + C_2 &= 0
$
// === page 44 ===
Solving these two algebraic equations for $D$ and $omega$ gives

#eqn("16")[$ D = frac(C_2, 2 I_L) $] <eq:2-16>

#eqn("17")[$ omega = sqrt(frac(C_1, I_L) - frac(C_2^2, 4 I_L^2)) $] <eq:2-17>

$A$ and $phi$ are now determined from the two _initial conditions_.
Let $alpha_x_0$ be the value of $alpha_x$ at $t=0$ and let $Omega_X_0$ be the value of $dif alpha_x/dif t$ at $t=0$.
Setting $t$ to zero in the formulae for $alpha_x$ and $dif alpha_x/dif t$ results in the following two expressions:

$!
  alpha_x_0 &= A sin phi \
  Omega_X_0 &= -A D sin phi + A omega cos phi \
             &= -D alpha_x_0 + A omega cos phi
$

from which

$!
  sin phi &= frac(alpha_x_0, A) \
  cos phi &= frac(D alpha_x_0 + Omega_X_0, A omega)
$

We now make use of the following trigonometric identity to evaluate $A$ and $phi$:

$! frac(sin phi, cos phi) = tan phi $

From this we have

#eqn("18")[$ tan phi = frac(alpha_x_0 omega, D alpha_x_0 + Omega_X_0) quad "or" quad phi = arctan(frac(alpha_x_0 omega, D alpha_x_0 + Omega_X_0)) $] <eq:2-18>

where the notation "arctan" has the interpretation, "that angle
// === page 45 ===
whose tangent is..."
From the expression for $sin phi$ it is also evident that

#eqn("19")[$ A = frac(alpha_x_0, sin phi) $] <eq:2-19>

and thus we have all the information we require to completely describe the rocket's angular motion.
Motion of this kind is called an _exponentially-damped sinusoid_ and its behavior is determined by the relative values of $I_L$, $C_1$, and $C_2$.

For $C_2=0$, the case of _zero damping_, the expression for yaw becomes

$! alpha_x = A sin(omega_n t + phi) $

where $omega_n = sqrt(C_1/I_L)$.
$omega_n$ is known as the _natural frequency_ of the rocket at the given airspeed.
The yaw response is _simple harmonic motion_: sinusoidal oscillations of angular frequency $omega_n$ at constant amplitude $A$, as shown in @fig:2-10.
This motion never really occurs, as there always exists some degree of aerodynamic damping; it is a so-called _limiting case_, meaning that it is closely approximated for very small values of $C_2/2I_L$.
Such vanishingly small damping is not desirable, for it means that the oscillations of the rocket will persist for many cycles without dying away.
Under such conditions the rocket will present a greater average frontal area to the airstream; consequently the drag will be increased.
Since there is also a side force on a yawed or pitched rocket, some altitude will be lost due to the resulting "ripple" in the flight path as the side force causes a side-to-side movement of the rocket considered as a
// === page 46 ===
#figure(
  image("/assets/figures-original/fig2-10.png"),
  caption: [Model rocket with zero damping undergoing simple harmonic motion in homogeneous response to general initial conditions in yaw.
  The time to reach the first zero, the period of the oscillation, and the relation of the initial conditions to the properties of the response are shown.
  A guide to interpreting the graph is presented below it, showing the rocket as it would appear at various times if viewed from the negative y axis.
  This and all subsequent calculations of dynamic response presented in this chapter are based on the assumption of constant airspeed, so that $C_1$ and $C_2$ do not change during the response.]
) <fig:2-10>
// === page 47 ===
whole.
For zero damping true alignment would never be regained.

I might remark at this point that Gurkin's "Basic Missile Aerodynamic Stability" contains references to quantities which are analogous to the natural frequency and the inverse time constant as defined in the present treatment.
The correspondence between my forms and those of Gurkin is as follows:

#table(
  columns: 3,
  [],
  [_Present Treatment_],
  [_Gurkin Report_],
  [Natural Frequency],
  [$ omega_n = sqrt(frac(C_1, I_L)) $],
  [$ omega_n = sqrt(frac(M_alpha, I)) $],
  [Inverse Time\ Constant],
  [$ D = frac(C_2, 2 I_L) $],
  [$ d = frac(M_q, 2 I) $],
)

For values of $C_1$, $C_2$, and $I_L$ such that $0 < C_2^2/(4I_L^2) < C_1/I_L$ we have the case of _underdamped motion_.
The oscillations have the appearance of a sine curve confined within a decaying exponential curve, as shown in @fig:2-11.
The angular frequency $omega$ is smaller than the natural frequency and the amplitude of the oscillations decreases toward zero with increasing time.
The characteristics of almost all model rockets are such that the homogeneous response will be of this nature at any reasonable airspeed.
This is a desirable type of behavior, for it is in this range of values of $C_2/2I_L$ that the _quickest restoration_ of the rocket to the intended direction of flight occurs.
If we define a _damping ratio_ $zeta$ by

#eqn("20")[$ zeta = frac(C_2, 2 sqrt(C_1 I_L)) $] <eq:2-20>

and agree to consider straight flight to have been restored when the magnitude of $alpha_x$ drops below and never again exceeds 5% of $A$, we find that the most rapid restoration occurs when $zeta = sqrt(2)/2$,
// === page 48 ===
#figure(
  image("/assets/figures-original/fig2-11.png"),
  caption: [Underdamped characteristic response to general initial conditions in yaw.
  The amplitude of the sinusoidal oscillation is confined within an exponentially-decaying "envelope" as shown by the dotted line.
  Also illustrated are the relation between the initial conditions and the characteristics of the response, the time to reach the first zero, and one-half the period required for one full oscillation.]
) <fig:2-11>
// === page 49 ===
or about .7071.
We therefore have the result

#eqn("21")[$ "optimum damping" equiv zeta = frac(sqrt(2), 2) $] <eq:2-21>

Surprisingly, $zeta > sqrt(2)/2$ results in a slower restoration.
This is because the decrease in angular frequency becomes more important than the decrease in the number of cycles required.
This decrease in angular frequency has another, more serious effect: it invalidates one of the assumptions on which this analysis is based.

The reader will recall my references to "side forces" and the side-to-side lateral motion of the rocket which they produce when angular oscillation is occurring.
This lateral motion necessarily involves the presence of velocity components normal (that is, at right angles) to the intended direction of flight.
Such velocity components, in turn, have the effect of reducing the apparent yaw angle "sensed" by the deflected rocket with the result that the effective corrective moment is reduced and the frequency of the oscillations is decreased below that predicted by the linearized theory which considers the CG of the rocket to undergo no lateral displacement.
Luckily, the frequencies at which most model rockets oscillate are such that the effect of lateral motion is far too small to be noticeable; _however_, should a given rocket have a very low frequency of oscillation for its mass (as it would if its damping ratio were high) the lateral displacements would become very large, so large, in fact, that the rocket might be very seriously deflected from its intended vertical trajectory.
Too high a damping ratio is thus a dangerous condition and should be avoided at all costs.
// === page 50 ===
To obtain a clearer picture of the effects of excessive damping, we can examine the predicted behavior of the rocket as $zeta$ increases past $sqrt(2)/2$.
Now we can express $omega$ in terms of the damping ratio as

$! omega = omega_n sqrt(1-zeta^2) $

For optimum damping at any airspeed, $omega$ is just $.7071 omega_n$.
As $zeta$ approaches 1.0, $omega$ approaches zero, and when a unity damping ratio is reached, the case of _critical damping_, the motion ceases to be oscillatory.
The form of solution given by Eq. #eqref(<eq:2-15>) is no longer valid.

For the case $zeta=1$, corresponding to $C_2^2/4I_L^2=C_1/I_L$, the solution to the dynamical equation has the form

#eqn("22")[$ alpha_x = (A_1 + A_2 t)e^(-D t) $] <eq:2-22>

The formulae for the time derivatives of $alpha_x$ are

$!
  frac(dif alpha_x, dif t) &= A_2 e^(-D t) - D(A_1 + A_2 t)e^(-D t) \
  frac(dif^2 alpha_x, dif t^2) &= D^2(A_1 + A_2 t)e^(-D t) - 2 A_2 D e^(-D t)
$

Substituting these in the dynamical equation and removing the common factor $e^(-D t)$ gives

$! I_L D^2(A_1 + A_2 t) - 2 I_L A_2 D + C_2 A_2 - C_2 D(A_1 + A_2 t) + C_1(A_1 + A_2 t) = 0 $

The terms involving $t$ must sum to zero independently of those not involving $t$.
Imposing this condition, we obtain
// === page 51 ===
$!
  I_L D^2 A_1 - 2 I_L A_2 D + C_2 A_2 - C_2 D A_1 + C_1 A_1 &= 0 \
  I_L D^2 A_2 - C_2 D A_2 + C_1 A_2 &= 0
$

Removing $A_2$ from the second equation and solving for $D$, we have

$! D = frac(C_2, 2 I_L) plus.minus sqrt(frac(C_2^2, 4 I_L^2) - frac(C_1, I_L)) $

But in this case we already know that $C_2^2/4I_L^2=C_1/I_L$.
The expression under the radical sign is zero and

$! D = frac(C_2, 2 I_L) quad "as before." $

If you substitute $C_2/I_L$ for $D$ in the first equation, you will find that the terms involving $A_2$ sum to zero.
It is then possible to remove the now-common factor of $A_1$ and obtain

$! C_1 - frac(C_2^2, 4 I_L) = 0 $

But if we divide this by $I_L$ we see that it is equivalent to

$! frac(C_1, I_L) - frac(C_2^2, 4 I_L^2) = 0 $

which we already know is true, since this is the case for which we are solving.
The differential equation therefore imposes no constraint on $A_1$ and $A_2$; these are determined by the initial conditions.
Setting $t=0$ in the expressions for $alpha_x$ and $dif alpha_x/dif t$, we have

$! alpha_x_0 = A_1 $
// === page 52 ===
$! Omega_X_0 = A_2 - D A_1 $

Then

#eqn("23")[$
  A_1 &= alpha_x_0 \
  A_2 &= Omega_X_0 + D alpha_x_0
$] <eq:2-23>

The motion for this case is illustrated in Figure 12.
Note that in this case $alpha_x$ never crosses to the opposite side of the $t$ axis from that on which it originates.
This behavior is said to exhibit _no overshoot_.
If $alpha_x_0$ and $Omega_X_0$ are both positive (as shown) or both negative there will be a single "peak" in the curve of yaw angle versus time before the angular displacement dies away; otherwise it dies away directly to zero.
Despite the fact that $A_2 t$ increases as time goes on, the decay of $e^(-D t)$ will eventually force the function as a whole to zero.
Critically damped motion is a good deal less desirable than motion of the oscillatory, underdamped variety.
The time to restore alignment is longer and the rocket will be shifted appreciably to one side by the action of the side force in one direction only for a substantial period of time.
The velocity involved in this lateral displacement will cause the rocket's flight path to take a noticeable "set", acquiring an inclination away from the intended vertical trajectory.

For the class of cases in which $C_2^2/(4I_L^2) > C_1/I_L$, or $zeta>1$, the homogeneous response is of the form

#eqn("24")[$ alpha_x = A_1 e^(-t/tau_1) + A_2 e^(-t/tau_2) $] <eq:2-24>

// === page 53 ===
#figure(
  image("/assets/figures-original/fig2-12.png"),
  caption: [Critically damped characteristic response to general initial conditions in yaw.
The yaw angle does not oscillate about zero, but approaches it asymptotically from above.
The relation of the initial conditions to the properties of the response has been shown.]
) <fig:2-12>
// === page 54 ===
where $tau_1$ and $tau_2$ are called the _time constants_ of the response.
The derivative formulae are

$! (dif alpha_x)/(dif t) = -A_1/tau_1 e^(-t/tau_1) - A_2/tau_2 e^(-t/tau_2) $

$! (dif^2 alpha_x)/(dif t^2) = A_1/tau_1^2 e^(-t/tau_1) + A_2/tau_2^2 e^(-t/tau_2) $

Substituting these expressions in the dynamical equation gives

$! I_L A_1/tau_1^2 e^(-t/tau_1) + I_L A_2/tau_2^2 e^(-t/tau_2) - C_2 A_1/tau_1 e^(-t/tau_1) - C_2 A_2/tau_2 e^(-t/tau_2) + C_1 A_1 e^(-t/tau_1) + C_1 A_2 e^(-t/tau_2) = 0 $

Those terms involving $A_1 e^(-t/tau_1)$ and those involving $A_2 e^(-t/tau_2)$ must sum to zero independently.
The two algebraic equations thus obtained, with common factors removed, are identical.
The form is

$! I_L/tau^2 - C_2/tau + C_1 = 0 $

Solving for $1/tau$, we obtain

$! 1/tau = C_2/(2 I_L) plus.minus sqrt(C_2^2/(4 I_L^2) - C_1/I_L) $

or

$! tau = 1/(C_2/(2 I_L) plus.minus sqrt(C_2^2/(4 I_L^2) - C_1/I_L)) $

We choose $tau_1$, called the _large_ time constant, as corresponding to the negative root.
$tau_2$, the _small_ time constant, corresponds to the positive root:
// === page 55 ===
#eqn("25")[
  $ tau_1 &= 1/(C_2/(2 I_L) - sqrt(C_2^2/(4 I_L^2) - C_1/I_L)) \
  tau_2 &= 1/(C_2/(2 I_L) + sqrt(C_2^2/(4 I_L^2) - C_1/I_L)) $
] <eq:2-25>

The condition $C_2^2/(4 I_L^2) > C_1/I_L$ for the validity of this solution is seen to be the requirement that the square root of a negative number not occur, and that there be two different time constants.
In the same way, the condition $C_1/I_L > C_2^2/(4 I_L^2)$ for the validity of the sinusoidal solutions was that the square root of a negative number not occur, and that there be _both_ a nonzero $omega$ and a value of $D$.
The constants $A_1$ and $A_2$ in Eq. #eqref(<eq:2-25>) are set by the initial conditions.
Writing $alpha_x_0$ and $Omega_X_0$ by setting $t = 0$ in the expressions for $alpha_x$ and $dif alpha_x/dif t$, we obtain

$! alpha_x_0 = A_1 + A_2 $

$! Omega_X_0 = -A_1/tau_1 - A_2/tau_2 $

Solving for $A_1$ and $A_2$ gives

#eqn("26")[
  $ A_1 &= (tau_1 alpha_x_0 + tau_1 tau_2 Omega_X_0)/(tau_1 - tau_2) \
  A_2 &= (tau_2 alpha_x_0 + tau_1 tau_2 Omega_X_0)/(tau_2 - tau_1) $
] <eq:2-26>

A response of this kind is called _overdamped_; its behavior is shown in @fig:2-13.
Like the critically-damped motion, the overdamped response has no overshoot; it also decays more slowly than a critically-damped response.
These features make overdamping an extremely hazardous condition.
With overdamping large changes in the flight path almost as severe as those resulting from neutral
// === page 56 ===
#figure(
  image("/assets/figures-original/fig2-13.png"),
  caption: [Overdamped characteristic response to general initial conditions in yaw, showing the relation of the initial conditions to the properties of the response.
The yaw angle returns to zero more slowly than in the critically damped case, and in the limit of infinite damping ratio the rocket would instantly lose its initial yaw rate and remain "stuck" at the initial yaw angle $alpha_x_0$ as if encased in very thick glue or tar.]
) <fig:2-13>
// === page 57 ===
static stability can occur if the rocket is disturbed; in fact, neutral static stability ($C_1 = 0$) is a limiting case of overdamped motion.

A statically unstable rocket (one whose corrective moment coefficient is _negative_) also responds to a disturbance in a manner described by equation (24).
Although the damping ratio is undefined for negative $C_1$, both time constants and both initial amplitudes are computable from Eqs. #eqref(<eq:2-25>) and #eqref(<eq:2-26>).
If you carry out these computations you will find that $tau_1$ becomes negative when $C_1$ is less than zero, so that $e^(-t/tau_1)$ becomes $e$ raised to a _positive power_.
The "exponential mode" associated with $tau_1$ thus _increases_ with time, meaning that the yaw angle of the rocket grows larger and larger as time goes on.
This is the dynamic description of a statically unstable rocket "going ape".
Such an _unstable_, or _divergent_, response is illustrated in @fig:2-14.
The statement "$C_1$ must be greater than zero" for a rocket to be stable is the dynamic equivalent of the statement "the center of pressure must lie aft of the center of gravity".
No matter what the phraseology employed to say it, positive static stability is the prime requirement of a successful rocket design.

==== Complete Response to Step Input <sec:2-3.1.2>

Suppose that a rocket which has been flying straight and true in calm air suddenly breaks into a region of the sky in which a wind of constant velocity is blowing parallel to the ground (such a phenomenon is called a _discontinuous wind shear_).
Or suppose such a rocket having four fins, each with a control tab, experiences a condition whereby the tabs on two opposing
// === page 58 ===
#figure(
  image("/assets/figures-original/fig2-14.png"),
  caption: [Characteristic response of a statically unstable rocket to general initial conditions in yaw, showing the relation of the initial conditions to the properties of the response.
The yaw angle does not return to zero, but rather _increases_ with time, so that the rocket will eventually flip end over end and execute completely unpredictable maneuvers.
Negative static stability is thus a dangerous condition and should always be avoided when designing model rockets.]
) <fig:2-14>

#figure(
  image("/assets/figures-original/fig2-15.png"),
  caption: [A step disturbance of intensity $M_s$.
Before $t = 0$ the yawing moment is zero; after $t = 0$ it is $M_s$ dyn-cm.]
) <fig:2-15>
// === page 59 ===
fins suddenly deflect an equal amount in the same direction.
Finally, consider what would happen if such a rocket experienced an engine or engine mounting malfunction in which the thrust line suddenly assumes an angle relative to the rocket's centerline.
Occurrences such as these fall into the category of _step inputs_, a name derived from the graphical appearance of their variation with respect to time.
The moment-versus-time graph of a representative step function appears in @fig:2-15.

A step input, for the purposes of this analysis, takes the form of an applied moment whose value is _zero before_ a given time and whose value is a _constant after_ that time.
The time at which the "step" occurs is considered to be $t = 0$.
With this convention we can define a step input in yaw mathematically as follows:

$! f_x(t) = 0 quad (t < 0) $

$! f_x(t) = M_s quad (t >= 0) $

A function of this form is, of course, an idealization.
You couldn't expect to observe a perfectly sharp step in any real physical quantity; nevertheless an analysis of the response of a rocket to a step input (hereafter abbreviated "step response") provides the designer with information of considerable value, for step-response analysis is one of the two standard methods of defining the relative ease with which a given rocket can be displaced from true alignment with its intended flight path.

We recall that the differential equation describing the response of a non-rolling rocket to forcing in yaw is

$! I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x = f_x(t) $
// === page 60 ===
Substituting our definition of the step input, we have

#eqn("27a")[
  $ I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x = 0 quad (t < 0) $
] <eq:2-27a>

#eqn("27b")[
  $ I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x = M_s quad (t >= 0) $
] <eq:2-27b>

Now I stipulated that the rocket under consideration be flying straight and evenly at the time the step is applied.
This is equivalent to stating that the yaw angle and all its time derivatives are zero for all time preceding the application of the step.
The rocket is said to be in a _rotationally quiescent state_ for $t < 0$ and you can see that such a condition identically satisfies Eq. #eqref(<eq:2-27a>).

Equation (27b) is solved by the _sum_ of the characteristic and particular responses (cf. Section 2.4).
The characteristic response, obtained in Section 3.1.1, is given by equation (15), equation (22), or equation (24), depending on the value of the quantity $C_1/I_L - C_2^2/(4 I_L^2)$.
The particular response in this case is

#eqn("28")[$ alpha_x = K $] <eq:2-28>

where $K$ is a constant.
Since a _constant cannot (by its very definition) vary with time_, all of its time derivatives are zero.
Upon substitution of $K$ for $alpha_x$, Eq. #eqref(<eq:2-27b>) thus becomes

$! C_1 K = M_s $

from which

#eqn("29")[$ K = M_s/C_1 $] <eq:2-29>
// === page 61 ===
The complete step-response for the cases in which $C_1/I_L > C_2^2/(4 I_L^2)$ is therefore

#eqn("30")[$ alpha_x = A e^(-D t) sin(omega t + phi) $] <eq:2-30>

where $D$ is given by equation (16) and $omega$ by equation (17).
As in Section 3.1.1, the values of $A$ and $phi$ are determined by the initial conditions.
It can be shown that, for a rocket quiescent before the application of the step input, both the angular displacement $alpha_x$ and the angular velocity $dif alpha_x/dif t$ are zero at $t = 0$.
Now setting time equal to zero in the expressions for $alpha_x$ and $dif alpha_x/dif t$ results in

$! alpha_x_0 = A sin phi + M_s/C_1 quad "and" $

$! Omega_X_0 = A(omega cos phi - D sin phi) $

which, when $alpha_x_0$ and $Omega_X_0$ are set equal to zero, give us

$! A sin phi = -M_s/C_1 quad "and" $

$! D sin phi = omega cos phi $

From the second of these we can obtain

#eqn("31a")[$ phi = arctan(omega/D) $] <eq:2-31a>

from which we have

#eqn("31b")[$ A = -M_s/(C_1 sin phi) $] <eq:2-31b>

The motion described by Eq. #eqref(<eq:2-30>) is an exponentially-damped sinusoid which oscillates about the offset horizontal line $alpha_x = M_s/C_1$.
For the case of zero damping it is simple harmonic
// === page 62 ===
#figure(
  image("/assets/figures-original/fig2-16.png"),
  caption: [Undamped response to a step disturbance in yaw.
The rocket oscillates indefinitely about the yaw angle $M_s/C_1$.
Also shown are the maximum yaw angle and the time at which it is first attained.]
) <fig:2-16>

#figure(
  image("/assets/figures-original/fig2-17.png"),
  caption: [Underdamped response to a step disturbance in yaw.
After a sufficiently long time the model will come to rest at the yaw angle $M_s/C_1$.
Also shown are the maximum yaw angle and the time at which it occurs.]
) <fig:2-17>
// === page 63 ===
motion about $alpha_x = M_s/C_1$ as shown in @fig:2-16.
The undamped oscillation varies in magnitude from zero to $2 M_s/C_1$, starting from zero with a zero angular velocity at time $t = 0$.
The underdamped case, which is again the desirable one for rocket behavior, is given in @fig:2-17.
The angular displacement, again starting with zero magnitude and slope, "homes in" in an oscillatory manner on the displaced axis at $M_s/C_1$.
It is of interest to compute the value of the first "peak" of such an oscillation and the time at which it occurs, since this information is useful in evaluating the merits of a given rocket design with respect to dynamic behavior.

The first peak will occur at the smallest _nonzero_ value of time for which the angular velocity is zero, i.e., for which $dif alpha_x/dif t = 0$.
Performing the operation of differentiation and setting the resulting expression equal to zero gives us

$! -A D e^(-D t) sin(omega t + phi) + A omega e^(-D t) cos(omega t + phi) = 0 $

from which, dividing by $A e^(-D t)$, we obtain

$! -D sin(omega t + phi) + omega cos(omega t + phi) = 0 $

This requires that

$! tan(omega t + phi) = omega/D $

Now if you take the inverse trigonometric function of both sides of this equation, you will wind up with

$! omega t + phi = arctan(omega/D) quad "or" $
// === page 64 ===
$! t = (arctan(omega/D) - phi)/omega $

But since $phi = arctan(omega/D)$, the only solution obtainable from this equation is $t = 0$.
While this is indeed a solution (our initial condition, $Omega_X = 0$, is based on it), it does not identify the time of occurrence of the first peak.
The _general solution_ for the time at which the _nth_ peak occurs is obtained by introducing the trigonometric identity

$! tan(omega t + phi + n pi) = tan(omega t + phi) quad (n " an integer") $

_Now_ if we take the inverse trigonometric functions we obtain

$! omega t + phi + n pi = arctan(omega/D) $

from which

$! t = n pi/omega $

The first peak occurs at the time associated with the value $n = 1$:

#eqn("32a")[$ t = pi/omega $] <eq:2-32a>

The value of $alpha_x$ at the first peak is computed by substituting this value of $t$ into Eq. #eqref(<eq:2-30>):

$! alpha_x bar_(t = pi/omega) = A e^(-pi D/omega) sin(pi + phi) + M_s/C_1 $

By the use of the trigonometric identity

$! sin(pi + phi) = -sin phi $
// === page 65 ===
and Eq. #eqref(<eq:2-31b>) this may be simplified to read

#eqn("32b")[$ alpha_x bar_(t = pi/omega) = M_s/C_1 [1 + e^(-pi D/omega)] $] <eq:2-32b>

A look at @fig:2-17 will reveal that this value of $alpha_x$ represents the greatest magnitude the angular displacement attains during the step-response.
Since the magnitude of the displacement _decreases_ as $C_1$ increases, we conclude that a large value of $C_1$ will reduce the severity of a rocket's step response.

In the case where the values of $C_1$, $C_2$, and $I_L$ are such that a condition of critical damping exists the complete step-response is given by

#eqn("33")[$ alpha_x = (A_1 + A_2 t)e^(-D t) + M_s/C_1 $] <eq:2-33>

where $D$ is again given by equation (16).
Applying the initial conditions, we have

$! alpha_x_0 = A_1 + M_s/C_1 = 0 quad "and" $

$! Omega_X_0 = A_2 - D A_1 = 0 $

from which we obtain

#eqn("34a")[$ A_1 = -M_s/C_1 $] <eq:2-34a>

#eqn("34b")[$ A_2 = -D M_s/C_1 $] <eq:2-34b>

A critically-damped step-response is shown in @fig:2-18.

The complete expression for an _overdamped_ step response is

#eqn("35")[$ alpha_x = A_1 e^(-t/tau_1) + A_2 e^(-t/tau_2) + M_s/C_1 $] <eq:2-35>
// === page 66 ===
#figure(
  image("/assets/figures-original/fig2-18.png"),
  caption: [Critically damped response to a step disturbance in yaw.
The yaw angle approaches a value of $M_s/C_1$ asymptotically from below.]
) <fig:2-18>

#figure(
  image("/assets/figures-original/fig2-19.png"),
  caption: [Overdamped response to a step disturbance in yaw.
The yaw angle $M_s/C_1$ is again approached asymptotically from below, but more slowly than is the case for the critically damped response.]
) <fig:2-19>

// === page 67 ===
where $tau_1$ and $tau_2$ are given by equations (25).
In this case the imposition of initial conditions results in the expressions

$! alpha_x_0 = A_1 + A_2 + M_s/C_1 = 0 $

and

$! Omega_X_0 = -A_1/tau_1 - A_2/tau_2 = 0 $

from which we have

#eqn("36a")[$ A_1 = -M_s tau_1/(C_1 (tau_1 - tau_2)) $] <eq:2-36a>

and

#eqn("36b")[$ A_2 = M_s tau_2/(C_1 (tau_1 - tau_2)) $] <eq:2-36b>

Figure 19 illustrates an overdamped step-response.

The critically-damped and overdamped step responses are both slower than the underdamped response, and in this sense the former are somewhat less sensitive to step inputs than the latter.
Consider what would happen, though, if the step were to arise, persist for a considerable length of time, and then drop to zero again.
An overdamped rocket would _also_ be slow in _returning_ to true alignment from a yaw angle of nearly $M_s/C_1$ radians.
Moreover, since overdamped responses exhibit no overshoot, the deflection of the flight path from the vertical would be substantially greater than in the case of underdamped motion.
It is therefore best to decrease a rocket's sensitivity to step inputs by the use of a large corrective moment coefficient rather than high damping.

==== Complete Response to Impulse Input <sec:2-3.1.3>

Imagine, if you will, that the rocket considered in Section 3.1.2 encounters a step input that does _not_ persist for all time
// === page 68 ===
$t >= 0$, but rather "steps down" to zero again after some interval of time $t_1$.
The graphical representation of this forcing function, as shown in @fig:2-20, forms a rectangle whose area is $M_s t_1$.
Now imagine the interval of time during which the step persists becoming shorter and shorter as the magnitude of the applied step input becomes greater and greater _in such a way that the product_ $M_s t_1$, _the area of the rectangle, remains constant_.
If we carry this process to its logical conclusion, we will ultimately arrive at a configuration such that $t_1$ is zero and $M_s$ is infinity.
In this case, however, $M_s$ must be considered a rather special "type" of infinity, since the product of "this" infinity with zero has a definite value: $M_s t_1$, which I shall hereafter denote by $H$.
A forcing function of this kind is called an _impulse of strength_ $H$, and the response of a given rocket to such an input offers a second criterion by which the resistance of the rocket to transient disturbances may be evaluated.
An impulsive input in yaw may be defined as follows:

$! f_x(t) = 0 quad (t != 0) $
$! f_x(t) = infinity quad (t = 0) $
$! 0 dot f_x(t) = H quad (t = 0) $

While there are more rigorous definitions of impulse inputs obtainable from the so-called _limiting arguments_ of the theory of _singularity functions_ (which includes, among other things, the study of steps and impulses), such formal precision is not necessary to an understanding of the effects of impulsive disturbances on physical systems.
Like the step, the impulse is an idealization of physical reality.
You know very well that a rocket can never encounter disturbing moments of infinite
// === page 69 ===
#figure(
  image("/assets/figures-original/fig2-20.png"),
  caption: [Development of the concept of an impulse from a series of steps of finite duration.
The step in (a) has an intensity $M_(s 1)$ and persists for a time $T_1$; the product $M_(s 1) T_1$ is equal to $H$ dyn-cm-sec.
The step in (b) has an intensity $M_(s 2)$ greater than $M_(s 1)$, but a duration $T_2$ less than $T_1$ such that the product $M_(s 2) T_2$ is still $H$ dyn-cm-sec.
The limiting case of this behavior is the impulse (c), a step of infinite intensity but infinitesimal duration such that the product of the intensity and the duration --- called the "strength" of the impulse --- is still $H$ dyn-cm-sec.]
) <fig:2-20>
// === page 70 ===
intensity and zero duration; any _strong_ disturbance of _short_ duration, however, can be treated as an impulse to a high order of accuracy.
Momentary fluctuations in the direction of the thrust line, oblique ejection of solid residue from the rocket nozzle, moments arising due to launcher contact during liftoff, and disturbances encountered during staging are examples of forcing functions which are virtually impulsive.

The response to an impulsive input is conceptually somewhat more difficult to grasp than the responses to other types of inputs.
In order to facilitate a consideration of the impulse response let me return to our discussion of the angular acceleration of the flywheel as illustrated in Figure 5.
Recall that, for a frictionless flywheel of inertial moment $I$ to which a constant moment $M$ is applied for a time $t$, the resulting angular velocity of the wheel is

$! omega = (M t)/I $

and the resulting angular displacement from the original rotative position is

$! alpha = 1/2 M/I t^2 $

Suppose, now, that the moment $M$ approaches infinity and the time $t$ approaches zero in such a way that the product $M t$ remains constant at the value $H$.
The angular velocity imparted to the wheel by the moment during the interval $t$ will, under these conditions remain constant at the value

$! omega = H/I $
// === page 71 ===
The angular displacement $alpha$, however, will decrease, since it is given by

$! alpha = H/(2 I) t $

When the limiting case is reached, the angular displacement will be zero.
The sole effect of an impulsive input to the flywheel is thus to cause a finite angular velocity to appear instantaneously at the time of application of the impulse.

The problem of the yawing rocket is precisely analogous, provided the damping and corrective moments are both zero: an impulse of strength $H$ will cause an angular velocity

$! Omega_X = H/I_L $

to arise instantaneously, while the angular displacement at time equal to zero will be zero.
Does the presence of nonzero corrective and damping moments in any way alter the state of the rocket at $t = 0$?

Well, it is clear that there cannot be any effect due to static stability, as no angular displacement of the rocket has yet occured; hence the corrective moment at $t = 0$ is itself zero.
And, although there does arise a damping moment simultaneously with the angular velocity increment due to the impulse, this moment is finite and therefore can produce no change in either the angular displacement or the angular velocity in a zero amount of time.
It thus turns out that the presence of aerodynamic moments does not modify the initial effect upon the rocket of an impulsive input.
This effect produces the following set
// === page 72 ===
of initial conditions:

#eqn("37a")[$ alpha_x_0 = 0 $] <eq:2-37a>

#eqn("37b")[$ Omega_X_0 = H/I_L $] <eq:2-37b>

Unlike the step, the impulse input has associated with it no particular response for $t > 0$.
More properly speaking, the particular response is zero, for as you can see from its definition the impulse itself is zero for all positive values of time.
A complete impulse response is actually a _homogeneous_ response with a special set of initial conditions: those given by equations (37).

The impulse-response of an underdamped rocket is given by equations (15) through (19).
Applying the initial conditions given in equations (37) results in the following values for the phase angle and the initial amplitude:

$! phi = arctan(0) = 0 $

$! A = H/(I_L omega) $

The characteristic response to an impulsive disturbance is then given by

#eqn("38")[$ alpha_x = H/(I_L omega) e^(-D t) sin omega t $] <eq:2-38>

where $omega$ and $D$ are determined by equations (16) and (17).
This motion is shown in @fig:2-21.

The critically-damped impulse response is described by equations (22) and (23).
In this case we have
// === page 73 ===
#figure(
  image("/assets/figures-original/fig2-21.png"),
  caption: [Underdamped response to an impulse of strength $H$ in yaw.
The initial angular velocity imparted by the impulse, the maximum yaw angle attained, and the time at which it occurs are shown.]
) <fig:2-21>
// === page 74 ===
$! A_1 = 0 $

$! A_2 = H/I_L $

and the characteristic motion assumes the form

#eqn("39")[$ alpha_x = H/I_L t e^(-D t) $] <eq:2-39>

where $D$ is again given by equation (16).
The impulse response of a critically-damped rocket is illustrated by @fig:2-22.

Overdamped motion resulting from impulsive forcing obeys equations (24) through (26).
Applying the initial conditions to these equations gives the results

$! A_1 = (H tau_1 tau_2)/(I_L (tau_1 - tau_2)) $

$! A_2 = -(H tau_1 tau_2)/(I_L (tau_1 - tau_2)) $

where $tau_1$ and $tau_2$ are determined by equation (25).
An overdamped rocket will thus exhibit an impulse-response described by

#eqn("40")[$ alpha_x = (H tau_1 tau_2)/(I_L (tau_1 - tau_2)) [e^(-t/tau_1) - e^(-t/tau_2)] $] <eq:2-40>

as illustrated in @fig:2-23.

Eq. #eqref(<eq:2-37b>) shows that the initial angular velocity resulting from an impulsive disturbance is inversely proportional to the longitudinal moment of inertia of the rocket which is being disturbed, and Eqs. #eqref(<eq:2-38>) through #eqref(<eq:2-40>) reveal an inverse dependence of the initial amplitude factors on the value of $I_L$.
It would thus seem that a large $I_L$ is desirable to reduce the severity of a rocket's impulse response.
We can
// === page 75 ===
#figure(
  image("/assets/figures-original/fig2-22.png"),
  caption: [Critically damped response to an impulse of strength $H$ in yaw, showing the initial yaw rate, the maximum yaw angle, and the time at which the maximum yaw angle occurs.]
) <fig:2-22>

#figure(
  image("/assets/figures-original/fig2-23.png"),
  caption: [Overdamped response to an impulse of strength $H$ in yaw, showing the initial yaw rate, the maximum yaw angle, and the time at which the maximum yaw angle is attained.
The maximum deflection occurs sooner and its value is smaller than is the case for the critically damped response, and the return to zero yaw angle is also more gradual.]
) <fig:2-23>
// === page 76 ===
investigate the quantities governing the severity of the response more thoroughly by deriving the maximum angular displacement associated with each case of impulse-response.
These maxima, and the values of $t$ at which they occur, can be computed by setting $dif alpha_x/dif t$ to zero and determining the smallest value of $t$ that will satisfy the resulting equation.

The equation resulting from imposing the condition of zero angular velocity on the underdamped case is

$! -(D H)/(I_L omega) e^(-D t) sin omega t + (omega H)/(I_L omega) e^(-D t) cos omega t = 0 $

from which we obtain

#eqn("41a")[$ t_m = arctan(omega/D)/omega $] <eq:2-41a>

so that

#eqn("41b")[$ alpha_(x m) = H/(I_L omega) e^(-D/omega arctan(omega/D)) sin [arctan(omega/D)] $] <eq:2-41b>

For the critically-damped motion we have

$! H/I_L e^(-D t) - (D H)/I_L t e^(-D t) = 0 $

from which

#eqn("42a")[$ t_m = 1/D $] <eq:2-42a>

and

#eqn("42b")[$ alpha_(x m) = H/(I_L D e) $] <eq:2-42b>

Finally, in the case of overdamped motion the applicable equation is

$! -(H tau_2)/(I_L tau_1 (tau_1 - tau_2)) e^(-t/tau_1) + (H tau_1)/(I_L tau_2 (tau_1 - tau_2)) e^(-t/tau_2) = 0 $

which gives us
// === page 77 ===
#eqn("43a")[$ t_m = (tau_1 tau_2 ln(tau_1/tau_2))/(tau_1 - tau_2) $] <eq:2-43a>

where the notation "ln" stands for the "natural logarithm of" the quantity in parentheses.
Natural logarithms, also called Naperian logarithms, are the mathematical inverse of exponential functions and may be found in tables arranged in much the same way as are tables of trigonometric functions.
From Eqs. #eqref(<eq:2-43a>) and #eqref(<eq:2-40>) we can obtain, after some algebraic manipulation,

#eqn("43b")[$ alpha_(x m) = (H tau_1 tau_2)/(I_L (tau_1 - tau_2)) [(tau_1/tau_2)^(-tau_2/(tau_1 - tau_2)) - (tau_1/tau_2)^(-tau_1/(tau_1 - tau_2))] $] <eq:2-43b>

Now if you substitute the expressions derived in Section 3.1.1 for $omega$, $D$, $tau_1$ and $tau_2$ into Eqs. #eqref(<eq:2-41b>), #eqref(<eq:2-42b>), and #eqref(<eq:2-43b>) you will make the following discoveries:

For underdamped motion, an increase in $I_L$ _decreases_ $alpha_(x m)$.

For critically-damped motion, changes in $I_L$ have _no effect_ on $alpha_(x m)$.

For overdamped motion, an increase in $I_L$ _increases_ $alpha_(x m)$.

These results might seem at first to indicate that large values of $I_L$ are desirable only in the case of underdamped motion.
This is not the whole story, however, for if we examine equation (20), in which the damping ratio $zeta$ is given as

$! zeta = C_2/(2 sqrt(C_1 I_L)) $

we see that an increase in $I_L$ invariably _reduces_ the damping ratio.
In particular, increasing $I_L$ can cause overdamped or critically-damped responses (which have already been shown to be undesirable
// === page 78 ===
in themselves) to become underdamped, after which _further_ increases in $I_L$ will _lessen_ the severity of the impulse response.

We can conclude from our analysis, then, that a large value of $I_L$ is a desirable design characteristic in a model rocket, as a large longitudinal moment of inertia helps both to guard against overdamping and to reduce the rocket's sensitivity to impulsive forcing.

==== Steady State Response to Sinusoidal Forcing <sec:2-3.1.4>

In the previous sections we were concerned with responses to forcing functions of a transient or discontinuous nature.
The behavior of a model rocket in these cases was such that both the homogeneous response and the particular response were of significant importance in determining the character of the resulting motion.
In cases where the disturbing moments are of a prolonged and periodic nature, however, the behavior of the characteristic response (which, for positive static stability and finite damping, dies away with time) soon creates a situation in which the particular response alone is of significant interest.
In the remainder of this section I am going to be talking about the properties of the particular response of a rocket having a zero roll rate to an input of the form

$! f_x(t) = A_f sin omega_f t $

The analysis will be based on the assumption that this "sinusoidal" input has been going on for a time sufficiently long that all transient phenomena have died away, so that the complete response is identical to the particular response alone.
The result obtained from an analysis based on such an assumption is
// === page 79 ===
often referred to as the _steady-state response to sinusoidal forcing_, or simply the _sinusoidal steady state_.
Such physical phenomena as periodic instability in the thrust line of the rocket motor and the aerodynamic "flutter" of fins or control tab surfaces are inputs which can be closely approximated by the sinusoidal representation.

Substituting the expression given above for $f_x(t)$ into equation (13) gives us the differential equation for the yawing oscillation in the form

$! I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x = A_f sin omega_f t $

The particular solution to this equation is known to be of the form

#eqn("44")[$ alpha_x = A_r sin(omega_f t + phi) $] <eq:2-44>

The rocket responds to the sinusoidal forcing with a sinusoidal motion of its own whose frequency is identical to the frequency of the disturbance.
The amplitude is different, however, and the response "leads" the forcing function by a phase angle of $phi$ radians.
The time derivatives of the response thus described are

$! (dif alpha_x)/(dif t) = omega_f A_r cos(omega_f t + phi) $

$! (dif^2 alpha_x)/(dif t^2) = -omega_f^2 A_r sin(omega_f t + phi) $

The values of $A_r$ and $phi$ are determined by substituting the expressions for $alpha_x$ and its time derivatives into the differential
// === page 80 ===
equation.
When this is done we obtain

$! -I_L omega_f^2 A_r sin(omega_f t + phi) + C_2 omega_f A_r cos(omega_f t + phi) + C_1 A_r sin(omega_f t + phi) = A_f sin omega_f t $

It is necessary to make use of the following trigonometric identities in order to solve this equation:

$! sin(omega_f t + phi) = sin omega_f t cos phi + cos omega_f t sin phi $

$! cos(omega_f t + phi) = cos omega_f t cos phi - sin omega_f t sin phi $

Substitution of the quantities on the right sides of these identities for those on the left sides in the differential equation casts it into the form

$! -I_L omega_f^2 A_r [sin omega_f t cos phi + cos omega_f t sin phi] + C_2 omega_f A_r [cos omega_f t cos phi - sin omega_f t sin phi] + C_1 A_r [sin omega_f t cos phi + cos omega_f t sin phi] = A_f sin omega_f t $

Now the terms containing $sin omega_f t$ and those containing $cos omega_f t$ must be independent.
This gives us two algebraic equations for $A_r$ and $phi$:

$! -I_L omega_f^2 A_r sin omega_f t cos phi - C_2 omega_f A_r sin omega_f t sin phi + C_1 A_r sin omega_f t cos phi = A_f sin omega_f t $

$! -I_L omega_f^2 A_r cos omega_f t sin phi + C_2 omega_f A_r cos omega_f t cos phi + C_1 A_r cos omega_f t sin phi = 0 $

// === page 81 ===
Dividing the first equation by $sin omega_f t$, the second by $A_r cos omega_f t$ simplifies these equations to

$! -I_L omega_f^2 A_r cos phi - C_2 omega_f A_r sin phi + C_1 A_r cos phi = A_f $

$! -I_L omega_f^2 sin phi + C_2 omega_f cos phi + C_1 sin phi = 0 $

Now the second equation can be divided by $cos phi$, producing a formulation containing the single trigonometric function $tan phi$:

$! [C_1-I_L omega_f^2] tan phi + C_2 omega_f = 0 $

The phase angle is then determined as

#eqn("45a")[$ phi = arctan [(C_2 omega_f)/(I_L omega_f^2-C_1)] $] <eq:2-45a>

The first equation may be divided by $cos phi$ to yield

$! A_r [(C_1-I_L omega_f^2)-C_2 omega_f tan phi] = A_f/(cos phi) $

The trigonometric identities

$! "sec" phi = 1/(cos phi) quad "and" $

$! "sec" phi = sqrt(tan^2 phi+1) $

then permit us to write

$! A_r [(C_1-I_L omega_f^2)-(C_2^2 omega_f^2)/(I_L omega_f^2-C_1)] = A_f sqrt((C_2^2 omega_f^2)/(I_L omega_f^2-C_1)^2+1) $

Some algebraic manipulation transforms this expression to:
// === page 82 ===
$! A_r [(I_L omega_f^2-C_1)^2+C_2^2 omega_f^2] = A_f sqrt((I_L omega_f^2-C_1)^2+C_2^2 omega_f^2) $

from which we conclude that

#eqn("45b")[$ A_r = A_f/sqrt((I_L omega_f^2-C_1)^2+C_2^2 omega_f^2) $] <eq:2-45b>

Now although equations (45) are perfectly acceptable solutions for $phi$ and $A_r$, there is a standard formulation of these results which greatly simplifies their interpretation.
Recall from @sec:2-3.1.1 that the natural frequency of the rocket is given by

$! omega_n = sqrt(C_1/I_L) $

while the damping ratio $zeta$ is given by equation (20):

$! zeta = C_2/(2 sqrt(C_1 I_L)) $

If we define a _frequency ratio_ $beta$ as

#eqn("46")[$ beta = omega_f/omega_n $] <eq:2-46>

and an _amplitude ratio_ $A R$ as

#eqn("47")[$ A R = A_r/A_f $] <eq:2-47>

we can, after some rearrangement, obtain the forms

#eqn("48a")[$ phi = arctan [(2 zeta beta)/(beta^2-1)] $] <eq:2-48a>
// === page 83 ===
#eqn("48b")[$ A R = 1/(C_1 sqrt((beta^2-1)^2+(2 zeta beta)^2)) $] <eq:2-48b>

Graphs of the variation of phase angle and amplitude ratio with frequency ratio for various values of $zeta$ are given in @fig:2-24 and @fig:2-25.
In @fig:2-24 the definition of the arctangent function has been artificially extended to run from $phi = 0$ to $phi = -pi$ radians so that the phase shift will appear as a continuous function of $beta$.
Notice that for all nonzero frequencies of disturbance the motion of the rocket _lags_ behind the input (that is, $phi$ is negative).
As $beta$ varies from zero to infinity $phi$ varies from zero to $-pi$ radians, passing through the value $(-pi/2)$ when $beta = 1.0$.

The more lightly damped the rocket, the more abrupt the transition from $phi = 0$ to $phi = -pi$; in the limiting case of zero damping the transition becomes discontinuous.
An examination of @fig:2-25 will reveal that, for rockets whose damping ratios are less than $sqrt(2)/2$, there exists a range of values of $beta$ distributed about $beta = 1$ in which the amplitude ratio has a value greater than $1/C_1$, its value for $beta = 0$.
This behavior is referred to as _resonance_; the greatest value of $A R$ attained is called the _resonance peak_ and the value of $omega_f$ at which it occurs is termed the _resonant frequency_.
These quantities are computed by locating the resonance peak analytically, using the fact that the slope of the amplitude-ratio curve is zero there.
The slope, or derivative of $A R$ with respect to $beta$, is given by the equation

$! (dif (A R))/(dif beta) = -[((beta^2-1)+2 zeta^2)(2 beta)]/(C_1 [(beta^2-1)^2+(2 zeta beta)^2]^(3/2)) $
// === page 84 ===
#figure(
  image("/assets/figures-original/fig2-24.png"),
  caption: [Variation of phase angle with frequency ratio for cases of steady-state response to sinusoidal forcing.]
) <fig:2-24>

#figure(
  image("/assets/figures-original/fig2-25.png"),
  caption: [Variation of amplitude ratio with frequency ratio for cases of steady-state response to sinusoidal forcing. Resonant behavior can be seen for damping ratios less than $sqrt(2)/2$, but does not occur at damping ratios greater than this value.]
) <fig:2-25>
// === page 85 ===
which is zero when its numerator is zero; that is when

$! beta^2-1+2 zeta^2 = 0 $

The value of $beta$ at resonance is therefore

#eqn("49a")[$ beta_"res" = sqrt(1-2 zeta^2) $] <eq:2-49a>

and the resonant frequency, $omega_"res"$, is given by

#eqn("49b")[$ omega_"res" = beta_"res" omega_n $] <eq:2-49b>

By substituting $beta_"res"$ for $beta$ in the equation for $A R$, we find that the resonance peak obeys the relation

#eqn("50")[$ A R_"res" = 1/(2 C_1 zeta sqrt(1-zeta^2)) $] <eq:2-50>

The value of $A R_"res"$ can be quite large if the rocket is only lightly damped, meaning that the amplitude of the response can be _much greater_ than that of the forcing function.
In fact, Eq. #eqref(<eq:2-50>) shows that the response amplitude increases _without bound_ as the damping ratio decreases and becomes _infinite_ at $zeta = 0$.
Resonance, therefore, can be an _extremely dangerous_ state, resulting in violent oscillation of the rocket and consequent deflection of its trajectory.
The designer of model rockets should spare no effort to minimize the effects of resonance.
The use of an adequate corrective moment coefficient (large enough static stability margin and adequate airspeed), the maintenance of a sufficient amount of damping, and the use of a flight velocity profile whereby the rocket passes quickly
// === page 86 ===
through the resonant state due to the resulting variation in $omega_n$ are three techniques generally employed in various combinations for this purpose.

As you can see from equations (49), the resonant frequency decreases from $omega_n$ toward zero as the damping ratio of the rocket increases from zero toward $sqrt(2)/2$.
This same variation in damping ratio causes the value of the resonance peak to decrease from infinity to $1/C_1$, and for $zeta > sqrt(2)/2$, there is no resonance peak at all; the value of $A R$ is always less than $1/C_1$.
Damping ratios greater than 0.7071 therefore result in the least severe response to disturbances of a steady sinusoidal nature.

=== Dynamical Behavior at a Constant, Nonzero Roll Rate <sec:2-3.2>

==== Generalized Homogeneous Response <sec:2-3.2.1>

The presence of a constant roll rate causes the pitching and yawing movements of the rocket to become coupled (cf. Section 2.3), so that the differential equations for pitch and yaw must be solved simultaneously.
We recall that the homogeneous differential equations for this case are

$! I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x + I_R omega_z (dif alpha_y)/(dif t) = 0 $

$! I_L (dif^2 alpha_y)/(dif t^2) + C_2 (dif alpha_y)/(dif t) + C_1 alpha_y - I_R omega_z (dif alpha_x)/(dif t) = 0 $

Although the general form of the solutions to these equations is somewhat similar to the solutions of the decoupled case, the complete solutions themselves are a good deal more complicated.
The most generally applicable ones are given by

#eqn("51")[
  $ alpha_x &= A_1 e^(-D_1 t) sin(omega_1 t+phi_1) + A_2 e^(-D_2 t) sin(omega_2 t+phi_2) \
  alpha_y &= A_1 e^(-D_1 t) cos(omega_1 t+phi_1) + A_2 e^(-D_2 t) cos(omega_2 t+phi_2) $
] <eq:2-51>
// === page 87 ===
Now it is clear that the derivative formulae for those parts of equations (51) which carry the subscript "2" will be identical in form to those for the terms which are subscripted with a "1".
I can therefore save a great deal of writing if, for now, I leave off the subscripts and just write down the derivatives of one term of each equation's right-hand member:

$! (dif alpha_x)/(dif t) = -A D e^(-D t) sin(omega t+phi) + A omega e^(-D t) cos(omega t+phi) $

$! (dif^2 alpha_x)/(dif t^2) = A(D^2-omega^2)e^(-D t) sin(omega t+phi) - 2 A omega D e^(-D t) cos(omega t+phi) $

$! (dif alpha_y)/(dif t) = -A D e^(-D t) cos(omega t+phi) - A omega e^(-D t) sin(omega t+phi) $

$! (dif^2 alpha_y)/(dif t^2) = A(D^2-omega^2)e^(-D t) cos(omega t+phi) + 2 A omega D e^(-D t) sin(omega t+phi) $

This amounts to pretending, for the present, that there is only one initial amplitude, only one inverse time constant, only one angular frequency and only one phase angle in the solution.
Such an intentional error is perfectly permissible, just as it was in deriving equations (25), for the mathematics of the derivation will later point out that there are in fact two each of these quantities.

Upon substitution of the simplified derivative relations the first (yaw) differential equation becomes

$! I_L A(D^2-omega^2)e^(-D t) sin(omega t+phi) - 2 I_L A omega D e^(-D t) cos(omega t+phi) \
-I_R omega_z A D e^(-D t) cos(omega t+phi) - I_R omega_z A omega e^(-D t) sin(omega t+phi) \
-C_2 A D e^(-D t) sin(omega t+phi) + C_2 A omega e^(-D t) cos(omega t+phi) + C_1 A e^(-D t) sin(omega t+phi) = 0 $

Removing the common factor $A e^(-D t)$ we have, from the requirement
// === page 88 ===
that sine terms sum independently to zero,

$! I_L(D^2-omega^2)-I_R omega_z omega-C_2 D+C_1 = 0 $

and from the requirement that cosine terms sum independently to zero,

$! -2 I_L omega D-I_R omega_z D+C_2 omega = 0 $

Substituting the expressions for $alpha$, $dif alpha/dif t$, and $dif^2 alpha/dif t^2$ into the second (pitch) equation gives

$! I_L A(D^2-omega^2)e^(-D t) cos(omega t+phi) + 2 I_L A omega D e^(-D t) sin(omega t+phi) \
+I_R omega_z A D e^(-D t) sin(omega t+phi) - I_R omega_z A omega e^(-D t) cos(omega t+phi) \
-C_2 A D e^(-D t) cos(omega t+phi) - C_2 A omega e^(-D t) sin(omega t+phi) + C_1 A e^(-D t) cos(omega t+phi) = 0 $

from which the cosine terms give us

$! I_L(D^2-omega^2)-I_R omega_z omega-C_2 D+C_1 = 0 $

and the sine terms require that

$! 2 I_L omega D+I_R omega_z D-C_2 omega = 0 $

Now the sine equation from the first differential equation is identical to the cosine equation from the second, and the cosine equation from the first just equals the negative of the sine equation from the second and is therefore equivalent to it.
This confirms that a coupled solution of the form (51) does in fact exist and that we can proceed to solve for $omega$ and $D$.
// === page 89 ===
From the last equation above we can obtain $D$ in terms of $omega$ as

$! D = (C_2 omega)/(2 I_L omega+I_R omega_z) $

Substituting this expression for $D$ into the second to last equation above yields

$! (I_L C_2^2 omega^2)/(4 I_L^2 omega^2+4 I_L I_R omega_z omega+I_R^2 omega_z^2) - I_L omega^2 - I_R omega_z omega - (C_2^2 omega)/(2 I_L omega+I_R omega_z) + C_1 = 0 $

Multiplying the left and right sides of this equation by $(4 I_L^2 omega^2+4 I_L I_R omega_z omega+I_R^2 omega_z^2)$, collecting terms and dividing the resulting equation by a factor of $(-4 I_L^3)$ to cast the equation into a form having a coefficient of 1 for the highest power of $omega$ which appears (this is called _normalizing_), we obtain

$! omega^4 + 2 (I_R/I_L) omega_z omega^3 + [-C_1/I_L + C_2^2/(4 I_L^2) + 5/4 (I_R^2/I_L^2) omega_z^2] omega^2 \
+[-C_1/I_L I_R/I_L omega_z + C_2^2/(4 I_L^2) I_R/I_L omega_z + I_R^3/(4 I_L^3) omega_z^3] omega - C_1/(4 I_L) I_R^2/I_L^2 omega_z^2 = 0 $

Now this is a _quartic_ equation in $omega$, in which all powers of $omega$ from the zeroth to the fourth are present.
The solution of such equations is generally quite difficult, but we can reduce the complexity somewhat in this case by considering the _physics_ of the situation and the _limiting behavior_ of the solutions, rather than just plowing ahead with the formal mathematics.
By "limiting behavior" I mean just this: should $I_R omega_z$ become vanishingly small compared to $I_L$, the solution of the coupled motion will be very nearly identical to the solution of the decoupled case.
A mathematician would say that the coupled solution _approaches_ the decoupled solution _in the limit_ as
// === page 90 ===
$I_R omega_z/I_L$ goes to zero, so that we recover the solution of the decoupled case from the _more general_ solution of coupled motion.
Similarly, for the case in which $C_1$ and $C_2$ become vanishingly small compared to $I_L$, we obtain the so-called _force-free precession_ which is familiar to the designers of gyroscopic instruments; the coupled solution approaches a force-free precession in the limit as $C_1/I_L$ and $C_2/I_L$ go to zero.
I am going to try to put these properties to use after making the following substitutions in order to simplify the algebra of the angular frequency equation:

$! X = I_R/I_L $

$! Y = -C_1/I_L $

$! Z = C_2^2/(4 I_L^2) $

The equation for $omega$ then becomes

#eqn("52a")[
  $ omega^4 + 2 X omega_z omega^3 + [Y+Z+5/4 X^2 omega_z^2] omega^2 \
  +[Y X omega_z+Z X omega_z+X^3/4 omega_z^3] omega+Y/4 X^2 omega_z^2 = 0 $
] <eq:2-52a>

Now since this is a fourth-degree polynomial equation, we know that there are four possible values of $omega$ which will satisfy it (the _roots_ of the equation).
Let these values be $A$, $B$, $C$, and $D$.
The equation can then be written as

$! (omega-A)(omega-B)(omega-C)(omega-D) = 0 $

which, when multiplied out, becomes
// === page 91 ===
#eqn("52b")[
  $ omega^4-(A+B+C+D)omega^3+[A B+C D+(A+B)(C+D)]omega^2 \
  -[C D(A+B)+A B(C+D)]omega+A B C D = 0 $
] <eq:2-52b>

Now equations (52a) and (52b) are just different representations of the _same_ equation.
This being the case, the coefficient of a given power of $omega$ in equation (52a) must be identical to the coefficient of that same power of $omega$ in equation (52b).
This allows us to write

#eqn("53a")[$ A+B+C+D = -2 X omega_z $] <eq:2-53a>

#eqn("53b")[$ [A B+C D+(A+B)(C+D)] = [Y+Z+5/4 X^2 omega_z^2] $] <eq:2-53b>

#eqn("53c")[$ [C D(A+B)+A B(C+D)] = -[Y X omega_z+Z X omega_z+X^3/4 omega_z^3] $] <eq:2-53c>

#eqn("53d")[$ A B C D = Y/4 X^2 omega_z^2 $] <eq:2-53d>

Equations (53) are sufficient to determine the roots $A$, $B$, $C$, and $D$ in terms of the constants $X$, $Y$, and $Z$.
This, however, would be an extremely difficult task if done by formal mathematics alone.
Instead I am going to examine the limiting behavior of this particular dynamical system --- a model rocket --- to see if I cannot find some analytical "short cut" that will help me to _guess_ the roots.

For $I_R omega_z/I_L = 0$, equation (52a) becomes

$! omega^4+(Y+Z)omega^2 = 0 $

Factoring this expression, we obtain
// === page 92 ===
$! omega^2(omega^2+Y+Z) = 0 $

Two of the roots are thus $omega = 0$.
The remaining two are

$! omega = plus.minus sqrt(-(Y+Z)) $

or

$! omega = plus.minus sqrt(C_1/I_L-C_2^2/(4 I_L^2)) $

which are just cases of decoupled, underdamped oscillation.

For the limiting case $C_1/I_L = C_2/I_L = 0$, we have $Y = Z = 0$ and equation (52a) becomes

$! omega^4+2 X omega_z omega^3+5/4 X^2 omega_z^2 omega^2+X^3/4 omega_z^3 omega = 0 $

Factoring gives us

$! omega(omega^3+2 X omega_z omega^2+5/4 X^2 omega_z^2 omega+X^3/4 omega_z^3) = 0 $

One of the four roots is seen to be $omega = 0$.
The remaining factor is a cubic equation and will therefore have three roots.
Let these be denoted by $A'$, $B'$, and $C'$.
Then

$! (omega-A')(omega-B')(omega-C') = 0 $

which, when expanded, becomes

$! omega^3-(A+B+C)omega^2+[(A+B)C+A B]omega-A B C = 0 $

Then, equating coefficients of like powers, we have

$! -(A+B+C) = 2 X omega_z $
// === page 93 ===
$! (A+B)C+A B = 5/4 X^2 omega_z^2 $

$! -A B C = X^3/4 omega_z^3 $

I can now exercise on a reduced scale the techniques which I shall have to apply to solve the general quartic equation (52a).
The _sum_ of the roots of the cubic equation must equal $-2 X omega_z$, while their _product_ must equal $-X^3/4 omega_z^3$.
From this I conclude that $A'$, $B'$, and $C'$ each contain a factor of $X omega_z$.
If I attempt, reasoning from symmetry, to postulate three equal roots you can see that the coefficient equations will not be satisfied.
If, however, I postulate _two identical_ roots and a different third root, the sum and product conditions will allow me to write

$! A' = -(X omega_z)/2 $

$! B' = -(X omega_z)/2 $

$! C' = -X omega_z $

These roots also satisfy the center coefficient equation, and _are_ therefore the roots of the cubic equation.
I am now faced with the problem of determining which of these roots are _physical_ (i.e., which can really be observed in the physical universe) and which are "spurious" or "extraneous" roots not applicable to the physical problem being solved.
In order to ascertain the physical roots I return to the equation obtained from the cosine
// === page 94 ===
terms of the pitch differential equation and set $C_1 = C_2 = 0$.
This sets $D$ to zero and leaves me with

$! -I_L omega^2-I_R omega_z omega = 0 $

from which I obtain the two roots

$! omega = 0 $

$! omega = -(I_R/I_L) omega_z $

The first value represents a static displacement in pitch and yaw, and is the root already obtained by factoring the quartic.
The second value represents the force-free precessional angular frequency of the rocket.
Both values represent observable physical states of the rocket; in fact, for general initial conditions a combination of _both_ states will occur.
There will thus be _two_ angular frequencies of oscillation associated with coupled motion, and we must be prepared to accept two of the four roots of the general quartic equation as physical possibilities.
In the reduced case of $Y = Z = 0$ these two roots are $omega = 0$ and root $C'$ of the cubic equation.
Roots $A'$ and $B'$ are non-physical and must be discarded.

Having thus obtained complete information as to the limiting behavior of equation (52a), I am prepared to postulate solutions to the general quartic equation.
Symmetry considerations and equation (53a) motivate me to guess that the roots are of the following form:

// === page 95 ===
$! A &= - frac(X omega_z, 2) + a \
B &= - frac(X omega_z, 2) - a \
C &= - frac(X omega_z, 2) + b \
D &= - frac(X omega_z, 2) - b $

You can see that these values identically satisfy equation (53a).

Equation (53b) becomes

$! frac(X^2 omega_z^2, 2) - (a^2 + b^2) + X^2 omega_z^2 = Y + Z + frac(5, 4) X^2 omega_z^2 $

from which we obtain

$! b^2 = -(Y + Z) + frac(X^2 omega_z^2, 4) - a^2 $

Equation (53c) now appears as

$! [(frac(X^2 omega_z^2, 4) - b^2)(-X omega_z) + (frac(X^2 omega_z^2, 4) - a^2)(-X omega_z)] = -X omega_z [Y + Z + frac(X^2 omega_z^2, 4)] $

and, upon substitution of the expression for $b^2$ obtained in (53b), is seen to be identically satisfied.

The final coefficient equation, (53d), becomes

$! (frac(X^2 omega_z^2, 4) - a^2)(frac(X^2 omega_z^2, 4) - b^2) = Y frac(X^2 omega_z^2, 4) $

Substituting for $b^2$ the expression obtained in (53b) we can obtain, after some rearrangement,

$! a^4 + [Y + Z - frac(X^2 omega_z^2, 4)] a^2 - Z frac(X^2 omega_z^2, 4) = 0 $

Now this is a special kind of quartic equation known as a
// === page 96 ===
_biquadratic equation_.

It can be solved as a quadratic equation for $a^2$ to give

$! a^2 = frac(X^2 omega_z^2, 8) - frac(Y + Z, 2) plus.minus frac(1, 2) sqrt((Y + Z - frac(X^2 omega_z^2, 4))^2 + Z X^2 omega_z^2) $

Solving for $b^2$ as obtained in (53b), we have

$! b^2 = frac(X^2 omega_z^2, 8) - frac(Y + Z, 2) minus.plus sqrt((Y + Z - frac(X^2 omega_z^2, 4))^2 + Z X^2 omega_z^2) $

Now there is an option here in that we can choose the upper or lower sign for the square root terms.

Having chosen a sign for the square root in $a^2$, however, we are obliged to choose the corresponding sign for that in $b^2$.

Choosing the upper sign in each case, we have the following expressions for the complete roots of the quartic equation:

#eqn("54")[
  $ A &= -frac(X omega_z, 2) + sqrt(frac(X^2 omega_z^2, 8) - frac(Y + Z, 2) + frac(1, 2) sqrt((Y + Z - frac(X^2 omega_z^2, 4))^2 + Z X^2 omega_z^2)) \
  B &= -frac(X omega_z, 2) - sqrt(frac(X^2 omega_z^2, 8) - frac(Y + Z, 2) + frac(1, 2) sqrt((Y + Z - frac(X^2 omega_z^2, 4))^2 + Z X^2 omega_z^2)) \
  C &= -frac(X omega_z, 2) + sqrt(frac(X^2 omega_z^2, 8) - frac(Y + Z, 2) - frac(1, 2) sqrt((Y + Z - frac(X^2 omega_z^2, 4))^2 + Z X^2 omega_z^2)) \
  D &= -frac(X omega_z, 2) - sqrt(frac(X^2 omega_z^2, 8) - frac(Y + Z, 2) - frac(1, 2) sqrt((Y + Z - frac(X^2 omega_z^2, 4))^2 + Z X^2 omega_z^2)) $
] <eq:2-54>

We must determine which of these give us the correct limiting behavior.

This is a rather tricky procedure in this case and must be carefully carried out step by step if inconsistencies are to be avoided.

For the case $X omega_z = 0$, the roots assume the form

$! A = sqrt(-frac(Y + Z, 2) + frac(1, 2) sqrt((Y + Z)^2)) $
// === page 97 ===
$! B = -sqrt(-frac(Y + Z, 2) + frac(1, 2) sqrt((Y + Z)^2)) \
C = sqrt(-frac(Y + Z, 2) - frac(1, 2) sqrt((Y + Z)^2)) \
D = -sqrt(-frac(Y + Z, 2) - frac(1, 2) sqrt((Y + Z)^2)) $

In simplifying these results we must bear in mind always the following rule of algebra: when a quantity is squared, and the square root of the number thus obtained is taken, all knowledge of the algebraic sign of the original quantity is _irrevocably lost_.

The final result of such a sequence of operations is the _absolute value_ of the original quantity, which is by definition a positive number.

In our example here,

$! sqrt((Y + Z)^2) = abs(Y + Z) $

$! equiv "the absolute value of (Y+Z)" $

Now

$! abs(Y + Z) = Y + Z quad "if" quad (Y + Z) > 0, quad "but" $

$! abs(Y + Z) = -(Y + Z) quad "if" quad (Y + Z) < 0 $

In discussing statically-stable rockets, we are referring always to the case in which $Y$ is negative (that is, $C_1$ is positive).

If we further stipulate that the motion be underdamped, we will always have $(Y + Z)$ negative.

Then

$! sqrt((Y + Z)^2) = -(Y + Z) $

and the roots become

$! A = sqrt(-(Y + Z)) \
B = -sqrt(-(Y + Z)) $
// === page 98 ===
$! C = 0 \
D = 0 $

Thus $A$ and $B$ are the roots which correctly describe the motion of an underdamped, statically-stable rocket in the limit of roll coupling equal to zero.

For the opposite limit, that of $Y = Z = 0$, we have

$! A &= -frac(X omega_z, 2) + sqrt(frac(X^2 omega_z^2, 8) + frac(1, 2) sqrt((-frac(X^2 omega_z^2, 4))^2)) \
B &= -frac(X omega_z, 2) - sqrt(frac(X^2 omega_z^2, 8) + frac(1, 2) sqrt((-frac(X^2 omega_z^2, 4))^2)) \
C &= -frac(X omega_z, 2) + sqrt(frac(X^2 omega_z^2, 8) - frac(1, 2) sqrt((-frac(X^2 omega_z^2, 4))^2)) \
D &= -frac(X omega_z, 2) - sqrt(frac(X^2 omega_z^2, 8) - frac(1, 2) sqrt((-frac(X^2 omega_z^2, 4))^2)) $

Now in this case

$! sqrt((-frac(X^2 omega_z^2, 4))^2) = frac(X^2 omega_z^2, 4) $

whereupon

$! A &= -frac(X omega_z, 2) + sqrt(frac(X^2 omega_z^2, 4)) \
B &= -frac(X omega_z, 2) - sqrt(frac(X^2 omega_z^2, 4)) \
C &= -frac(X omega_z, 2) \
D &= -frac(X omega_z, 2) $

Also,

$! sqrt(frac(X^2 omega_z^2, 4)) = frac(X omega_z, 2) quad "if" quad omega_z > 0, quad "but" $

$! sqrt(frac(X^2 omega_z^2, 4)) = -frac(X omega_z, 2) quad "if" quad omega_z < 0 $
// === page 99 ===
so that if $omega_z > 0$,

$! A = 0 \
B = -X omega_z $

while if $omega_z < 0$,

$! A = -X omega_z \
B = 0 $

Thus $A$ and $B$ are the physical roots in the limit of force-free precession as well as in the limit of decoupled motion.

$C$ and $D$ are spurious roots and must be discarded.

The two angular frequencies $A$ and $B$ describe the complete spectrum of dynamic behavior as we proceed continuously from motion dominated by roll coupling to motion dominated by aerodynamic moments (except in a few very special cases to be pointed out later).

From this point on I am going to refer to root $A$ as angular frequency $omega_1$, and to root $B$ as angular frequency $omega_2$.

The larger of the two will be called "the fast mode", the smaller "the slow mode".

If $omega_z$ is positive, $omega_1$ will be the slow mode and $omega_2$ the fast mode; if $omega_z$ is negative, the reverse will be true (recall that a positive $omega_z$ means that the rocket is spinning clockwise as viewed from astern).

I am also going to adopt the abbreviation

$! cal(F) = frac(X^2 omega_z^2, 4) - (Y + Z) $

which may be written in terms of the rocket's dynamic constants as
// === page 100 ===
#eqn("55")[
  $ cal(F) = frac(I_R^2 omega_z^2, 4 I_L^2) + frac(C_1, I_L) - frac(C_2^2, 4 I_L^2) $
] <eq:2-55>

Under this convention the two angular frequencies appear as

#eqn("56a")[
  $ omega_1 = -frac(I_R omega_z, 2 I_L) + sqrt(frac(cal(F), 2) + frac(1, 2) sqrt(cal(F)^2 + frac(C_2^2 I_R^2 omega_z^2, 4 I_L^4))) $
] <eq:2-56a>

#eqn("56b")[
  $ omega_2 = -frac(I_R omega_z, 2 I_L) - sqrt(frac(cal(F), 2) + frac(1, 2) sqrt(cal(F)^2 + frac(C_2^2 I_R^2 omega_z^2, 4 I_L^4))) $
] <eq:2-56b>

Since a complete description of the coupled motion of the rocket for general initial conditions must contain both modes, each with its own initial amplitude and its own phase angle, equations (51) must indeed be the solution to the problem.

Substituting $omega_1$ and $omega_2$, in turn, into the equation

$! D = frac(C_2 omega, 2 I_L omega + I_R omega_z) $

obtained earlier, we obtain the values

#eqn("57a")[
  $ D_1 = frac(C_2, 2 I_L) (frac(omega_1, omega_1 + frac(I_R, 2 I_L) omega_z)) $
] <eq:2-57a>

#eqn("57b")[
  $ D_2 = frac(C_2, 2 I_L) (frac(omega_2, omega_2 + frac(I_R, 2 I_L) omega_z)) $
] <eq:2-57b>

for the two inverse time constants.

Note that these both reduce to $C_2/(2 I_L)$ for the case where the roll rate is zero.

The values of $A_1$, $A_2$, $phi_1$, and $phi_2$ are determined by the four initial conditions, which are:

$! alpha_x_0 = "value of" alpha_x "at" t = 0 $

$! alpha_y_0 = "value of" alpha_y "at" t = 0 $

$! Omega_X_0 = "value of" dif alpha_x / dif t "at" t = 0 $

$! Omega_Y_0 = "value of" dif alpha_y / dif t "at" t = 0 $
// === page 101 ===
From equations (51) and their time derivatives we have that

$! alpha_x_0 = A_1 sin phi_1 + A_2 sin phi_2 $

$! alpha_y_0 = A_1 cos phi_1 + A_2 cos phi_2 $

$! Omega_X_0 = -A_1 D_1 sin phi_1 + A_1 omega_1 cos phi_1 - A_2 D_2 sin phi_2 + A_2 omega_2 cos phi_2 $

$! Omega_Y_0 = -A_1 D_1 cos phi_1 - A_1 omega_1 sin phi_1 - A_2 D_2 cos phi_2 - A_2 omega_2 sin phi_2 $

This system of four independent equations in four unknowns is reduced by eliminating terms between the equations one by one until explicit formulae for the initial amplitudes and phase angles are obtained.

Beginning this process with the angular velocity equations, for instance, I can write

$! D_1 Omega_X_0 + omega_1 Omega_Y_0 = -A_1 sin phi_1 (D_1^2 + omega_1^2) - A_2 sin phi_2 (D_1 D_2 + omega_1 omega_2) + A_2 cos phi_2 (omega_2 D_1 - omega_1 D_2) $

$! D_2 Omega_X_0 + omega_2 Omega_Y_0 = -A_1 sin phi_1 (D_1 D_2 + omega_1 omega_2) - A_2 sin phi_2 (D_2^2 + omega_2^2) + A_1 cos phi_1 (omega_1 D_2 - omega_2 D_1) $

Now if you substitute $alpha_y_0 - A_2 cos phi_2$ for $A_1 cos phi_1$ in the second equation and subtract it from the first you will get

$! [Omega_X_0 (D_1 - D_2) + Omega_Y_0 (omega_1 - omega_2) + alpha_y_0 (omega_1 D_2 - omega_2 D_1)] = [A_1 sin phi_1 (D_1 D_2 + omega_1 omega_2 - D_1^2 - omega_1^2) + A_2 sin phi_2 (D_2^2 + omega_2^2 - D_1 D_2 - omega_1 omega_2)] $

Multiplying the equation for $alpha_x_0$ by the factor $(D_2^2 + omega_2^2 - D_1 D_2 - omega_1 omega_2)$ and subtracting the result _from_ this equation results in the expression

$! A_1 sin phi_1 [2(D_1 D_2 + omega_1 omega_2) - D_1^2 - D_2^2 - omega_1^2 - omega_2^2] = [Omega_X_0 (D_1 - D_2) + Omega_Y_0 (omega_1 - omega_2) + alpha_y_0 (omega_1 D_2 - omega_2 D_1) + alpha_x_0 (D_1 D_2 + omega_1 omega_2 - D_2^2 - omega_2^2)] $
// === page 102 ===
from which we can obtain

$! A_1 sin phi_1 = frac(Omega_X_0 (D_1 - D_2) + Omega_Y_0 (omega_1 - omega_2) + alpha_x_0 (D_1 D_2 + omega_1 omega_2 - D_2^2 - omega_2^2) + alpha_y_0 (omega_1 D_2 - omega_2 D_1), 2(D_1 D_2 + omega_1 omega_2) - D_1^2 - D_2^2 - omega_1^2 - omega_2^2) $

By a similar sequence of algebraic operations we can obtain the value of $A_1 cos phi_1$:

$! omega_1 Omega_X_0 - D_1 Omega_Y_0 = A_1 cos phi_1 (omega_1^2 + D_1^2) + A_2 sin phi_2 (omega_2 D_1 - omega_1 D_2) + A_2 cos phi_2 (omega_1 omega_2 + D_1 D_2) $

$! omega_2 Omega_X_0 - D_2 Omega_Y_0 = A_1 cos phi_1 (omega_1 omega_2 + D_1 D_2) + A_1 sin phi_1 (omega_1 D_2 - omega_2 D_1) + A_2 cos phi_2 (omega_2^2 + D_2^2) $

Substituting $alpha_x_0 - A_2 sin phi_2$ for $A_1 sin phi_1$ and subtracting,

$! [Omega_X_0 (omega_1 - omega_2) + Omega_Y_0 (D_2 - D_1) + alpha_x_0 (omega_1 D_2 - omega_2 D_1)] = [A_1 cos phi_1 (omega_1^2 + D_1^2 - omega_1 omega_2 - D_1 D_2) + A_2 cos phi_2 (omega_1 omega_2 + D_1 D_2 - omega_2^2 - D_2^2)] $

Multiplying $alpha_y_0$ by $(omega_1 omega_2 + D_1 D_2 - omega_2^2 - D_2^2)$ and subtracting the result from the above gives us

$! [Omega_X_0 (omega_1 - omega_2) + Omega_Y_0 (D_2 - D_1) + alpha_x_0 (omega_1 D_2 - omega_2 D_1) + alpha_y_0 (omega_2^2 + D_2^2 - omega_1 omega_2 - D_1 D_2)] = A_1 cos phi_1 [omega_1^2 + D_1^2 + omega_2^2 + D_2^2 - 2(omega_1 omega_2 + D_1 D_2)] $

Multiplying both sides of this by $(-1)$ and performing the appropriate division, we obtain

$! A_1 cos phi_1 = frac(Omega_X_0 (omega_2 - omega_1) + Omega_Y_0 (D_1 - D_2) + alpha_x_0 (omega_2 D_1 - omega_1 D_2) + alpha_y_0 (omega_1 omega_2 + D_1 D_2 - omega_2^2 - D_2^2), 2(omega_1 omega_2 + D_1 D_2) - D_1^2 - D_2^2 - omega_1^2 - omega_2^2) $
// === page 103 ===
Dividing $A_1 sin phi_1$ by $A_1 cos phi_1$ and taking the inverse tangent function of both sides of the resulting equation will give us an explicit formula for $phi_1$ in terms of the initial conditions, angular frequencies, and inverse time constants:

#eqn("58a")[
  $ phi_1 = arctan [frac(Omega_X_0 (D_1 - D_2) + Omega_Y_0 (omega_1 - omega_2) + alpha_x_0 (omega_1 omega_2 + D_1 D_2 - omega_2^2 - D_2^2) + alpha_y_0 (omega_1 D_2 - omega_2 D_1), Omega_X_0 (omega_2 - omega_1) + Omega_Y_0 (D_1 - D_2) + alpha_x_0 (omega_2 D_1 - omega_1 D_2) + alpha_y_0 (omega_1 omega_2 + D_1 D_2 - omega_2^2 - D_2^2))] $
] <eq:2-58a>

$phi_2$ is now computed from the relations

$! A_2 sin phi_2 = alpha_x_0 - A_1 sin phi_1 $

$! A_2 cos phi_2 = alpha_y_0 - A_1 cos phi_1 $

This time, since $A_1 sin phi_1$ and $A_1 cos phi_1$ are both quantities which we have already computed for use in finding $phi_1$, we can immediately write

#eqn("58b")[
  $ phi_2 = arctan [frac(alpha_x_0 - A_1 sin phi_1, alpha_y_0 - A_1 cos phi_1)] $
] <eq:2-58b>

Both phase angles are now known and their sine and cosine functions can be determined from trigonometric tables.

Since we also know the explicit formulae for $A_1 sin phi_1$ and $A_2 sin phi_2$, we can compute the initial amplitudes as follows:

#eqn("59a")[
  $ A_1 = frac(A_1 sin phi_1, sin phi_1) $
] <eq:2-59a>

#eqn("59b")[
  $ A_2 = frac(A_2 sin phi_2, sin phi_2) $
] <eq:2-59b>
// === page 104 ===
Equations (51) and (55) through (59) contain all the information necessary to completely describe the angular oscillations of a rolling model rocket in pitch and yaw.

For general initial conditions, both the pitching and yawing motions are sums of two different exponentially-damped sinusoids.

The appearance of the motion is generally quite complicated.

The slower mode sets the basic pattern: the nose of the rocket describes an inward spiral toward the position of zero deflection if the rocket is statically stable, an outward spiral if it is statically unstable, and a circle of constant radius if either (1) the corrective moment coefficient $C_1$ is zero, or (2) the corrective moment coefficient is positive but the damping moment coefficient $C_2$ is zero.

The faster mode may impose intricate secondary motions called _nutations_ upon the basic pattern if it is sufficiently high in frequency and its amplitude is small.

As in the case of decoupled motion, however, the characteristics of the oscillations are dependent upon the relative values of the rocket's inertial and aerodynamic constants.

For the case of zero damping ($C_2 = 0$) the function $cal(F)$ becomes

$! cal(F) = frac(I_R^2 omega_z^2, 4 I_L^2) + frac(C_1, I_L) $

From which we have

$! omega_1 = -frac(I_R omega_z, 2 I_L) + sqrt(frac(I_R^2 omega_z^2, 4 I_L^2) + frac(C_1, I_L)) $

$! omega_2 = -frac(I_R omega_z, 2 I_L) - sqrt(frac(I_R^2 omega_z^2, 4 I_L^2) + frac(C_1, I_L)) $

as long as $cal(F)$ is positive, which it certainly will be for statically-stable rockets.

Since $C_2$ is zero, $D_1$ and $D_2$ will
// === page 105 ===
both be zero and the expressions describing the motion become

#eqn("60a")[
  $ alpha_x = A_1 sin(omega_1 t + phi_1) + A_2 sin(omega_2 t + phi_2) $
] <eq:2-60a>

#eqn("60b")[
  $ alpha_y = A_1 cos(omega_1 t + phi_1) + A_2 cos(omega_2 t + phi_2) $
] <eq:2-60b>

Both pitch and yaw are the sum of two simple harmonic motions.

The oscillations do not decay; they persist indefinitely at undiminished amplitudes as shown in @fig:2-26.

Needless to say, this condition is undesirable; as in the decoupled case, the restoration of the rocket to a position in which it is facing directly along the intended flight path never occurs.

Since damping is always present in some degree, however slight, this case will not be literally observed for any real rocket.

But, as in decoupled motion, too little damping can result in an oscillation that continues for an undesirably long time.

For nonzero damping such that

$! frac(cal(F), 2) + frac(1, 2) sqrt(cal(F)^2 + frac(C_2^2 I_R^2 omega_z^2, 4 I_L^4)) > frac(I_R^2 omega_z^2, 4 I_L^2) $

coupled, positively-stable motion described by the complete forms of equations (51) and (55) through (59) will occur.

The angular frequency of the fast mode will be opposite in sign to that of the slow mode; the fast mode will be of opposite sign to the roll rate, while the sign of the slow mode will be the same as that of the roll rate.

The damping coefficients $D_1$ and $D_2$ will both be positive, meaning that the amplitudes of both modes will _decay_ exponentially with time.

The inverse time constant associated with the slow mode will be smaller in magnitude than that associated with the fast mode; the slow mode will
// === page 106 ===
#figure(
  image("/assets/figures-original/fig2-26.png"),
  caption: [Undamped homogeneous response to general initial conditions in yaw and pitch of a model rocket spinning about its longitudinal axis at a nonzero roll rate $omega_z$. The relation of the initial conditions to the properties of the response has been illustrated. The pattern of pitching and yawing motions shown repeats itself periodically for all time, as there is no damping to dissipate the angular momentum of the oscillations.]
) <fig:2-26>
// === page 107 ===
therefore be a _more slowly decaying_ mode than the fast mode.

The fast mode decays more rapidly than a decoupled oscillation with the same values of $C_1$, $C_2$, and $I_L$, while the slow mode decays more slowly than such a decoupled oscillation.

As a practical matter this means that the slow mode will be the most important part of the oscillation after a sufficient time has elapsed, so that roll coupling serves to _reduce the effectiveness of damping_.

A representative case of coupled, positively-stable motion is shown in @fig:2-27.

It is in this range of relative values of $C_1$, $C_2$, and $I_L$ that the designer wants his model rocket to lie; under no other conditions do the oscillations subside, whether the rocket is rolling or not.

The condition which must be satisfied for roll-coupled characteristic motion to be positively stable can be made more explicit by solving the inequality

$! frac(cal(F), 2) + frac(1, 2) sqrt(cal(F)^2 + frac(C_2^2 I_R^2 omega_z^2, 4 I_L^4)) > frac(I_R^2 omega_z^2, 4 I_L^2) $

for $cal(F)$.

We can express this relation as

$! sqrt(cal(F)^2 + frac(C_2^2 I_R^2 omega_z^2, 4 I_L^4)) > frac(I_R^2 omega_z^2, 2 I_L^2) - cal(F) $

Squaring both sides and collecting terms, we have

$! frac(C_2^2 I_R^2 omega_z^2, 4 I_L^4) > frac(I_R^4 omega_z^4, 4 I_L^4) - cal(F) frac(I_R^2 omega_z^2, I_L^2) $

from which it can be seen that

$! cal(F) > frac(I_R^2 omega_z^2, 4 I_L^2) - frac(C_2^2, 4 I_L^2) $
// === page 108 ===
#figure(
  image("/assets/figures-original/fig2-27.png"),
  caption: [Characteristic response of a model rocket with finite damping and nonzero roll rate to general initial conditions in yaw and pitch, showing the relation of the initial conditions to the properties of the response. Both the yawing and pitching oscillations eventually decay to zero and the model regains straight and true flight.]
) <fig:2-27>

// === page 109 ===
Upon examining the original expression for $cal(F)$ given in equation (55), we see that this is just the requirement that

$! C_1 > 0 $

_Positive static stability is thus required for positively stable characteristic motion, whether or not the rocket is spinning about its centerline._
As the value of

$! cal(F)/2 + 1/2 sqrt(cal(F)^2 + (C_2^2 I_R^2 omega_z^2)/(4 I_L^4)) $

decreases toward $(I_R^2 omega_z^2)/(4 I_L^2)$ (that is, as the corrective moment coefficient decreases toward zero), the angular frequency of the fast mode approaches a value of $-(I_R omega_z)/I_L$ while that of the slow mode approaches zero from above if $omega_z$ is positive, from below if $omega_z$ is negative.
The inverse time constant of the fast mode approaches $C_2/I_L$, or twice the damping of the decoupled oscillation, but that of the _slow mode approaches zero_.
At $C_1 = 0$ the rocket remains deflected indefinitely; it is neutrally stable, just as if it were not rolling.
As $C_1$ becomes _negative_, so that

$! cal(F)/2 + 1/2 sqrt(cal(F)^2 + (C_2^2 I_R^2 omega_z^2)/(4 I_L^4)) < (I_R^2 omega_z^2)/(4 I_L^2) $

the inverse time constant of the slow mode _also becomes negative_: the angular deflection of the rocket from its intended direction of flight _increases with time_.
A rocket with a negative corrective moment coefficient is unstable, as emphasized above, whether it is rolling or not.
There is no fundamental change in the character of the rocket's
// === page 110 ===
motion as damping gains ascendancy over corrective moment, as there is in the case of decoupled motion, but the effect of too much damping is every bit as serious in the case of roll-coupled oscillation as it is for decoupled response.
The condition of critical damping for rockets whose roll rate is zero, you may remember, is

$! C_1/I_L = C_2^2/(4 I_L^2) $

Under this condition $cal(F)$ becomes simply $(I_R^2 omega_z^2)/(4 I_L^2)$, and

$! cal(F)/2 + 1/2 sqrt(cal(F)^2 + (C_2^2 I_R^2 omega_z^2)/(4 I_L^4)) = (I_R^2 omega_z^2)/(8 I_L^2) + 1/2 sqrt((I_R^2 omega_z^2)/(4 I_L^2) ((I_R^2 omega_z^2)/(4 I_L^2) + C_2^2/I_L^2)) $

Now

$! (I_R^2 omega_z^2)/(4 I_L^2) + C_2^2/I_L^2 > (I_R^2 omega_z^2)/(4 I_L^2) $

and therefore

$! 1/2 sqrt((I_R^2 omega_z^2)/(4 I_L^2) ((I_R^2 omega_z^2)/(4 I_L^2) + C_2^2/I_L^2)) > (I_R^2 omega_z^2)/(8 I_L^2) $

It follows that

$! cal(F)/2 + 1/2 sqrt(cal(F)^2 + (C_2^2 I_R^2 omega_z^2)/(4 I_L^4)) > (I_R^2 omega_z^2)/(4 I_L^2) $

so that the motion _is_ stable, no matter how great the value of $C_2$.
This, of course, is consistent with our result that the value of $C_1$ alone determines the stability of the oscillation.
But the slow mode, you will recall, will have an inverse time constant whose value is less than that of the inverse time constant of an identical rocket which is not rolling; therefore _the same condition which produces critical damping in a non-rolling rocket will, in an identical rocket which is rolling, produce an oscillation that decays more slowly than a critically-damped response_.
The
// === page 111 ===
condition

$! C_2^2/(4 I_L^2) > C_1/I_L $

which produces overdamping in rockets which are not rolling, will aggravate this undesirable state of affairs, making the rate at which the deflections subside even less.
Deflection amplitudes which are _large_ and which persist for _long periods of time_ can thus result from the same conditions which produce critically-damped or overdamped behavior in non-rolling rockets, so it remains good design practice to keep

$! C_1/I_L > C_2^2/(4 I_L^2) $

for any model rocket, rolling or not.

==== Complete Response to Step Input <sec:2-3.2.2>

In this section I am going to derive the equations describing the angular oscillations of a rolling model rocket subjected to a step input in yaw alone, of the same form as that considered in Section 3.1.2.
This can be done without loss of generality because the principle of superposition (Section 2.4) permits us to obtain the solution of the effect of each component of a step input having both pitch and yaw components separately, and then to add the solutions thus obtained to form the complete solution.
It is also true that the response to a step in pitch is analogous to the response to a step in yaw, so that everything a designer needs to know can be learned by doing the yaw problem alone.
For this same reason the impulse response of Section 3.1.3 will be done assuming the only disturbing moment to act about the yaw axis.
// === page 112 ===
Before time equal to zero, when the value of the step disturbance is zero, the coupled dynamical equations appear as

$! I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x + I_R omega_z (dif alpha_y)/(dif t) = 0 \
I_L (dif^2 alpha_y)/(dif t^2) + C_2 (dif alpha_y)/(dif t) + C_1 alpha_y - I_R omega_z (dif alpha_x)/(dif t) = 0 $

As in Section 3.1.2, we are considering a rocket whose pitch and yaw states are quiescent before the application of the step.
The solution to the above equations is therefore

$! alpha_x = alpha_y = 0 $

which, as you can see, identically satisfies them both.
After the step disturbance rises to the value $M_s$ the equations become

$! I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x + I_R omega_z (dif alpha_y)/(dif t) = M_s \
I_L (dif^2 alpha_y)/(dif t^2) + C_2 (dif alpha_y)/(dif t) + C_1 alpha_y - I_R omega_z (dif alpha_x)/(dif t) = 0 $

The particular solution to this set of equations is known to be

#eqn("61")[$ alpha_x &= M_s/C_1 \
alpha_y &= 0 $] <eq:2-61>

The complete solution to the coupled step response for time greater than zero is then

#eqn("62a")[$ alpha_x = A_1 e^(-D_1 t) sin(omega_1 t + phi_1) + A_2 e^(-D_2 t) sin(omega_2 t + phi_2) + M_s/C_1 $] <eq:2-62a>

#eqn("62b")[$ alpha_y = A_1 e^(-D_1 t) cos(omega_1 t + phi_1) + A_2 e^(-D_2 t) cos(omega_2 t + phi_2) $] <eq:2-62b>
// === page 113 ===
where $omega_1$ and $omega_2$ are given by equations (56) and $D_1$ and $D_2$ are given by equations (57).
$A_1$, $A_2$, $phi_1$, and $phi_2$ are determined by the initial conditions of the motion, which, for a quiescent state prior to the disturbance, are all zero:

$! alpha_x_0 = A_1 sin phi_1 + A_2 sin phi_2 + M_s/C_1 \
== 0 $

$! alpha_y_0 = A_1 cos phi_1 + A_2 cos phi_2 \
== 0 $

$! Omega_X_0 = -A_1 D_1 sin phi_1 + A_1 omega_1 cos phi_1 - A_2 D_2 sin phi_2 + A_2 omega_2 cos phi_2 \
== 0 $

$! Omega_Y_0 = -A_1 D_1 cos phi_1 - A_1 omega_1 sin phi_1 - A_2 D_2 cos phi_2 - A_2 omega_2 sin phi_2 \
== 0 $

These equations can be cast into the form of the initial condition equations used in Section 3.2.1 for determining the values of the initial amplitudes and phase angles given in equations (58) and (59) by rewriting them in the following manner:

$! -M_s/C_1 = A_1 sin phi_1 + A_2 sin phi_2 $

$! 0 = A_1 cos phi_1 + A_2 cos phi_2 $

$! 0 = -A_1 D_1 sin phi_1 + A_1 omega_1 cos phi_1 - A_2 D_2 sin phi_2 + A_2 omega_2 cos phi_2 $

$! 0 = -A_1 D_1 cos phi_1 - A_1 omega_1 sin phi_1 - A_2 D_2 cos phi_2 - A_2 omega_2 sin phi_2 $

By analogy with the corresponding solutions to the equations of Section 3.2.1 we can then write

$! A_1 sin phi_1 = M_s/C_1 [(omega_2^2 + D_2^2 - omega_1 omega_2 - D_1 D_2)/(2(D_1 D_2 + omega_1 omega_2) - D_1^2 - D_2^2 - omega_1^2 - omega_2^2)] $
// === page 114 ===
$! A_1 cos phi_1 = M_s/C_1 [(omega_1 D_2 - omega_2 D_1)/(2(omega_1 omega_2 + D_1 D_2) - omega_1^2 - D_1^2 - omega_2^2 - D_2^2)] $

from which we obtain

#eqn("63a")[$ phi_1 = arctan [(omega_2^2 + D_2^2 - omega_1 omega_2 - D_1 D_2)/(omega_1 D_2 - omega_2 D_1)] $] <eq:2-63a>

Then, using the relations

$! A_2 sin phi_2 = -A_1 sin phi_1 - M_s/C_1 $

$! A_2 cos phi_2 = -A_1 cos phi_1 $

we have

$! A_2 sin phi_2 = M_s/C_1 [(omega_1^2 + D_1^2 - omega_1 omega_2 - D_1 D_2)/(2(omega_1 omega_2 + D_1 D_2) - omega_1^2 - D_1^2 - omega_2^2 - D_2^2)] $

$! A_2 cos phi_2 = M_s/C_1 [(omega_2 D_1 - omega_1 D_2)/(2(omega_1 omega_2 + D_1 D_2) - omega_1^2 - D_1^2 - omega_2^2 - D_2^2)] $

and therefore, that

#eqn("63b")[$ phi_2 = arctan [(omega_1^2 + D_1^2 - omega_1 omega_2 - D_1 D_2)/(omega_2 D_1 - omega_1 D_2)] $] <eq:2-63b>

The values of the initial amplitudes are then obtained from the identities

#eqn("64a")[$ A_1 = (A_1 sin phi_1)/(sin phi_1) $] <eq:2-64a>

#eqn("64b")[$ A_2 = (A_2 sin phi_2)/(sin phi_2) $] <eq:2-64b>

The special case of zero damping is obtained by setting $D_1 = D_2 = 0$.
The characteristic appearance of this kind of motion should by now be familiar to you, so I won't bother to
// === page 115 ===
illustrate it.
The coupled step response of a stable rocket with nonzero damping is shown in @fig:2-28.
As in Section 3.1.2, the severity of the step response is inversely proportional to the (positive) magnitude of the corrective moment coefficient.
The desirability of a large corrective moment coefficient is therefore undiminished by the presence of a nonzero roll rate.

==== Complete Response to Impluse Input <sec:2-3.2.3>

Should a rocket which is spinning about its longitudinal axis encounter an impulsive disturbance acting about its yaw axis and of strength $H$, it may be verified by an argument similar to the one used in Section 3.1.3 that the initial effect of the impulse is identical to the effect of the same impulse upon the rocket when it is _not_ rolling: an initial yaw rate of value $H/I_L$ arises instantaneously.
The subsequent motion is a roll-coupled characteristic response governed by equations (51) and (55) through (59) with initial conditions $alpha_x_0$, $alpha_y_0$, and $Omega_Y_0$ all equal to zero and initial condition $Omega_X_0$ equal to $H/I_L$.
The impulse response is thus given by equations (51),

$! alpha_x = A_1 e^(-D_1 t) sin(omega_1 t + phi_1) + A_2 e^(-D_2 t) sin(omega_2 t + phi_2) $

$! alpha_y = A_1 e^(-D_1 t) cos(omega_1 t + phi_1) + A_2 e^(-D_2 t) cos(omega_2 t + phi_2) $

where $omega_1$ and $omega_2$ are given by equations (56) and $D_1$ and $D_2$ are computed according to equations (57).
Substituting the values of the initial conditions into the equations used in deriving equation (58a), we have
// === page 116 ===
#figure(
  image("/assets/figures-original/fig2-28.png"),
  caption: [Roll-coupled response of a model rocket with finite damping to a step of intensity $M_s$ in yaw. Both yawing and pitching oscillations occur; the pitching motion, however, decays to zero while the yaw angle eventually approaches the value $M_s/C_1$.]
) <fig:2-28>
// === page 117 ===
$! A_1 sin phi_1 = H/I_L [(D_1 - D_2)/(2(D_1 D_2 + omega_1 omega_2) - D_1^2 - D_2^2 - omega_1^2 - omega_2^2)] $

$! A_1 cos phi_1 = H/I_L [(omega_2 - omega_1)/(2(D_1 D_2 + omega_1 omega_2) - D_1^2 - D_2^2 - omega_1^2 - omega_2^2)] $

from which we conclude that

#eqn("65a")[$ phi_1 = arctan [(D_1 - D_2)/(omega_2 - omega_1)] $] <eq:2-65a>

The equations used in deriving (58b) become

$! A_2 sin phi_2 = -A_1 sin phi_1 $

$! A_2 cos phi_2 = -A_1 cos phi_1 $

and thus yield the result

#eqn("65b")[$ phi_2 = phi_1 $] <eq:2-65b>

A simplification of notation is then possible, in that the single value $phi = phi_1 = phi_2$ may be applied to the phase angles of both modes.
The equations for the initial amplitudes thus become

#eqn("66a")[$ A_1 = (A_1 sin phi)/(sin phi) $] <eq:2-66a>

#eqn("66b")[$ A_2 = -A_1 $] <eq:2-66b>

so that the initial amplitude of the first mode may be denoted by $A$, that of the second mode by $(-A)$.
The roll-coupled impulse response may then be written in the simplified form
// === page 118 ===
#eqn("67")[$ alpha_x &= A [e^(-D_1 t) sin(omega_1 t + phi) - e^(-D_2 t) sin(omega_2 t + phi)] \
alpha_y &= A [e^(-D_1 t) cos(omega_1 t + phi) - e^(-D_2 t) cos(omega_2 t + phi)] $] <eq:2-67>

The coupled impulse response of a representative, statically-stable model rocket having a finite amount of damping is illustrated in @fig:2-29.
Although the analytically explicit forms of the equations governing the maximum angular displacement experienced in a roll-coupled impulse response are prohibitively complicated, it will be found that a large value of the longitudinal moment of inertia $I_L$ is desirable, as it was in the decoupled case, in order to minimize the severity of the response.
This characteristic of the behavior is (again as before) connected with the inverse dependence of the initial amplitude terms on $I_L$.

==== Steady State Response to Sinusoidal Forcing at the Roll Rate <sec:2-3.2.4>

While it is certainly possible for a rocket having a zero roll rate to experience sinusoidal forcing of the various types described in Section 3.1.4, it turns out that the vast majority of cases of sinusoidal motion encountered in practice are due to causes arising from the spinning of the rocket itself.
Aerodynamic and inertial asymmetries and thrust misalignments, which appear as step disturbances to non-rolling rockets, become to a rolling rocket sinusoidal forcing functions whose angular frequency is identical to the rocket's roll rate.
For this reason the roll-coupled pitch- and yaw-dynamics of cylindrical projectiles under sinusoidal forcing are usually analyzed only for the case $omega_f = omega_z$.
// === page 119 ===
#figure(
  image("/assets/figures-original/fig2-29.png"),
  caption: [Roll-coupled response of a model rocket with finite damping to an impulse of strength $H$ in yaw. Again, both pitching and yawing oscillations occur; the yawing motion, however, begins instantaneously with an angular velocity of $H/I_L$, while the initial pitch rate is zero.]
) <fig:2-29>
// === page 120 ===
I shall adhere to this convention and treat, in the remainder of this section, the particular response of a rolling rocket to forcing functions of the form

$! f_x(t) = A_f sin omega_z t $

$! f_y(t) = A_f cos omega_z t $

The dynamical equations that must be solved become, in this case,

$! I_L (dif^2 alpha_x)/(dif t^2) + C_2 (dif alpha_x)/(dif t) + C_1 alpha_x + I_R omega_z (dif alpha_y)/(dif t) = A_f sin omega_z t \
I_L (dif^2 alpha_y)/(dif t^2) + C_2 (dif alpha_y)/(dif t) + C_1 alpha_y - I_R omega_z (dif alpha_x)/(dif t) = A_f cos omega_z t $

The particular solution to these equations is known to be of the form

$! alpha_x = A_r sin(omega_z t + phi) $

$! alpha_y = A_r cos(omega_z t + phi) $

where $A_r$ and $phi$ are to be determined by substitution, as in Section 3.1.4.
The time derivatives of these expressions are

$! (dif alpha_x)/(dif t) = A_r omega_z cos(omega_z t + phi) $

$! (dif^2 alpha_x)/(dif t^2) = -A_r omega_z^2 sin(omega_z t + phi) $

$! (dif alpha_y)/(dif t) = -A_r omega_z sin(omega_z t + phi) $

$! (dif^2 alpha_y)/(dif t^2) = -A_r omega_z^2 cos(omega_z t + phi) $
// === page 121 ===
Substituting these into the dynamical equations yields the following set of algebraic equations:

$! -I_L A_r omega_z^2 sin(omega_z t + phi) + C_2 A_r omega_z cos(omega_z t + phi) + C_1 A_r sin(omega_z t + phi) \
-I_R A_r omega_z^2 sin(omega_z t + phi) = A_f sin omega_z t $

$! -I_L A_r omega_z^2 cos(omega_z t + phi) - C_2 A_r omega_z sin(omega_z t + phi) + C_1 A_r cos(omega_z t + phi) \
-I_R A_r omega_z^2 cos(omega_z t + phi) = A_f cos omega_z t $

Making use of the trigonometric identities

$! sin(omega_z t + phi) = sin omega_z t cos phi + cos omega_z t sin phi $

$! cos(omega_z t + phi) = cos omega_z t cos phi - sin omega_z t sin phi $

we can obtain

$! A_r [C_1 - omega_z^2 (I_L + I_R)] [sin omega_z t cos phi + cos omega_z t sin phi] \
+ C_2 A_r omega_z [cos omega_z t cos phi - sin omega_z t sin phi] = A_f sin omega_z t $

$! A_r [C_1 - omega_z^2 (I_L + I_R)] [cos omega_z t cos phi - sin omega_z t sin phi] \
- C_2 A_r omega_z [sin omega_z t cos phi + cos omega_z t sin phi] = A_f cos omega_z t $

The terms containing $sin omega_z t$ and those containing $cos omega_z t$ must be independent of each other.
We then have, from the first relation above,

$! A_r cos phi [C_1 - omega_z^2 (I_L + I_R)] - A_r sin phi C_2 omega_z = A_f $

$! A_r sin phi [C_1 - omega_z^2 (I_L + I_R)] + A_r cos phi C_2 omega_z = 0 $
// === page 122 ===
From the second equation we see that

$! A_r cos phi [C_1 - omega_z^2 (I_L + I_R)] - A_r sin phi C_2 omega_z = A_f $

$! -A_r sin phi [C_1 - omega_z^2 (I_L + I_R)] - A_r cos phi C_2 omega_z = 0 $

The two sets of equations are entirely equivalent; either pair can be chosen for determining $A_r$ and $phi$.
Suppose I choose the first pair.
The second member of this pair gives us

#eqn("68a")[$ phi = arctan [(C_2 omega_z)/(omega_z^2 (I_L + I_R) - C_1)] $] <eq:2-68a>

The first member, when divided by $cos phi$, becomes

$! A_r [C_1 - omega_z^2 (I_L + I_R)] - A_r [(C_2^2 omega_z^2)/(omega_z^2 (I_L + I_R) - C_1)] = A_f "sec" phi $

which, upon substitution of the trigonometric identity

$! "sec" phi = sqrt(tan^2 phi + 1) $

may be written in the form

$! A_r [C_1 - omega_z^2 (I_L + I_R) - (C_2^2 omega_z^2)/(omega_z^2 (I_L + I_R) - C_1)] = A_f sqrt((C_2^2 omega_z^2)/([omega_z^2 (I_L + I_R) - C_1]^2) + 1) $

This can readily be transformed into

$! A_r {[omega_z^2 (I_L + I_R) - C_1]^2 + C_2^2 omega_z^2} = A_f sqrt([omega_z^2 (I_L + I_R) - C_1]^2 + C_2^2 omega_z^2) $

from which we obtain

#eqn("68b")[$ A_r = A_f/sqrt([omega_z^2 (I_L + I_R) - C_1]^2 + C_2^2 omega_z^2) $] <eq:2-68b>

// === page 123 ===
Equations (68) are precisely analogous to equations (45) (Section 3.1.4); the only difference between the two pairs of formulae is that the quantity $I_L$ in equations (45) has been replaced by $(I_L + I_R)$ in equations (68).
We can therefore conduct the remainder of the present analysis exactly as we did in the case of the non-rolling rocket, with the aid of a few definitions:

#eqn("69")[$ omega_(n c) = sqrt(C_1 / (I_L + I_R)) $] <eq:2-69>

#eqn("70")[$ zeta_c = C_2 / (2 sqrt(C_1 (I_L + I_R))) $] <eq:2-70>

#eqn("71")[$ beta_c = omega_z / omega_(n c) $] <eq:2-71>

#eqn("72")[$ A R_c = A_r / A_f $] <eq:2-72>

It is important to remember, however, that the quantities defined by equations (69) and (70) are highly artificial constructions created solely for the purpose of analytical convenience.
The _effective natural frequency_ $omega_(n c)$ does not correspond to any real, physical angular frequency at which the rocket can be expected to oscillate if undamped; neither does the _effective damping ratio_ $zeta_c$ bear any relation to any damping parameter we can compute from the characteristics of the homogeneous response, as was the case for non-rolling rockets.
Both $omega_(n c)$ and $zeta_c$ are excellent analytical tools, though, since they give us a maximum amount of information about the rocket with a minimum of writing, so you shouldn't let their somewhat tenuous physical bases bother you too much.
Using equations (69) through (72) we can write, by analogy
// === page 124 ===
with equations (46) through (48)

#eqn("73a")[$ phi = arctan((2 zeta_c beta_c) / (beta_c^2 - 1)) $] <eq:2-73a>

#eqn("73b")[$ A R_c = 1 / (C_1 sqrt((beta_c^2 - 1)^2 + (2 zeta_c beta_c)^2)) $] <eq:2-73b>

and, for the roll coupled resonant frequency and resonance peak,

#eqn("74a")[$ beta_(c "res") = sqrt(1 - 2 zeta_c^2) $] <eq:2-74a>

#eqn("74b")[$ omega_(c "res") = beta_(c "res") omega_(n c) $] <eq:2-74b>

#eqn("75")[$ A R_(c "res") = 1 / (2 C_1 zeta_c sqrt(1 - zeta_c^2)) $] <eq:2-75>

@fig:2-30 and @fig:2-31 illustrate the variation in $phi$ and $A R_c$ with $beta_c$ for a number of different values of $zeta_c$.
These functions are, of course, identical to those illustrated in Figures 24 and 25.

All the dangers inherent in decoupled resonant responses are present also in the roll-coupled case, all the more so since the presence of a roll rate decreases the effective damping and makes the resonance peak of any given rocket more severe.
In rockets that are not slender enough for $I_R$ to be negligible compared to $I_L$ the difference between the decoupled and coupled resonant responses can be significant.
The effect of spinning upon a short, stubby rocket can be truly startling; it can even be serious enough to render unacceptable a design whose behavior might otherwise be within tolerable limits.

From our analysis of the roll-coupled sinusoidal steady state we thus conclude that a large _slenderness ratio_ in the sense of a large ratio of $I_L$ to $I_R$, as well as in the sense of
// === page 125 ===
#figure(
  image("/assets/figures-original/fig2-30.png"),
  caption: [Figure 30: Variation of coupled phase angle with coupled frequency ratio in cases of roll-coupled response to sinusoidal forcing in pitch and yaw at the roll rate.]
) <fig:2-30>

#figure(
  image("/assets/figures-original/fig2-31.png"),
  caption: [Figure 31: Variation of coupled amplitude ratio with coupled frequency ratio in cases of roll-coupled response to sinusoidal forcing in pitch and yaw at the roll rate.]
) <fig:2-31>
// === page 126 ===
a large value of $I_L$ itself, is to be ranked along with a large corrective moment coefficient and an adequate damping coefficient as a design feature useful in minimizing the hazards of resonance.

==== Roll Stabilization <sec:2-3.2.5>

Since the early days of model rocketry it has been known that the flight path of a model which has an insufficient, or even slightly negative, static stability margin can be rendered reasonably straight and true by inducing a very rapid roll rate in the vehicle at launch.
This technique generally goes by the name of _spin stabilization_ or _roll stabilization_ and it is widely believed that the presence of a rapid enough roll rate actually induces positive aerodynamic stability in an otherwise unstable rocket.
As an examination of the relevant dynamical equations will reveal, it does nothing of the kind.

First of all, we have our results from Section 3.2.1 which indicate that the angle of deflection of a _statically-unstable_ rocket from its intended direction of flight increases with time after the rocket is disturbed, just as it does for a statically-unstable rocket which is not rolling at all.
The only case in which the presence of a finite roll rate prevents an unstable rocket from diverging is that of zero damping (equations (60)), in which negative values of $C_1$ up to, but not including, $- (I_R^2 omega_z^2) / (4 I_L)$ can be tolerated while an oscillation which neither grows nor decays with time is maintained.
What happens when $C_1$ reaches the critical value $- (I_R^2 omega_z^2) / (4 I_L)$?
Well, if $C_1$ is precisely $- (I_R^2 omega_z^2) / (4 I_L)$ the solution to the dynamical equations assumes the form
// === page 127 ===
#eqn("76")[$
  alpha_x &= A_1 sin(omega_c t + phi_1) + A_2 t sin(omega_c t + phi_2) \
  alpha_y &= A_1 cos(omega_c t + phi_1) + A_2 t cos(omega_c t + phi_2)
$] <eq:2-76>

where $omega_c$, the _critical frequency_, is given by

$! omega_c = - I_R / (2 I_L) omega_z $

Because equations (76) constitute a freak case which is of no interest whatsoever from the standpoint of design, I will not go into any detailed derivations of its properties.
Suffice it to say that equations (76) describe a response which grows with time and is thus unstable.

Should $C_1$ have a larger negative value than $- (I_R^2 omega_z^2) / (4 I_L)$ a motion of the form

#eqn("77")[$
  alpha_x &= A_1 e^(-t / tau_1) sin(omega_c t + phi_1) + A_2 e^(-t / tau_2) sin(omega_c t + phi_2) \
  alpha_y &= A_1 e^(-t / tau_1) cos(omega_c t + phi_1) + A_2 e^(-t / tau_2) cos(omega_c t + phi_2)
$] <eq:2-77>

will be observed where, again, $omega_c = - I_R / (2 I_L) omega_z$.
The values of the time constants are given by

#eqn("78a")[$ tau_1 = 1 / sqrt(-(C_1 / I_L + (I_R^2 omega_z^2) / (4 I_L^2))) $] <eq:2-78a>

#eqn("78b")[$ tau_2 = - tau_1 $] <eq:2-78b>

Again, since this is a singular case never encountered in practice there is no useful purpose served in presenting its full derivation.
Its only useful purpose is to confirm that a divergent dynamical response results from $C_1 < - (I_R^2 omega_z^2) / (4 I_L)$.
We see that this is indeed
// === page 128 ===
the case, as the time constant $tau_2$ is negative and will thus cause the amplitude of the sinusoidal mode with which it is associated to increase exponentially with time.
I might mention here in passing that the behavior described by equations (76) and (77) through (78) is very like the “running down” of a toy top or gyroscope.
Indeed, the equations involved are rather similar, so if you have such a device handy you might want to observe the decay of its motion a couple of times to get a “feel” for what the mathematics is saying.

At any rate, what we have established so far is that in the idealization of zero damping (which never occurs anyway) a rocket spinning at a rate $omega_z$ is capable of tolerating negative stability up to, but not including, $C_1 = - (I_R^2 omega_z^2) / (4 I_L)$ without diverging (albeit without the oscillations _subsiding_ either, so that the motion is really only neutrally stable in the dynamic sense).
Beyond this value the oscillations increase in violence until the rocket flips end for end entirely, destroying all semblance of a true and predictable flight path.
In the _real_ case of finite damping, moreover, _any_ negative value of $C_1$, _no matter how slight_, results in unstable flight.
What, then, does roll stabilization really do?

_It suppresses the growth rate of the instability._
A close look at equations (57) will help to clarify my meaning here.
Both the inverse time constants $D_1$ and $D_2$ involve a fraction whose _denominator contains the term_ $(I_R omega_z) / (2 I_L)$.
This means that for a large enough radial moment of inertia, a fast enough roll rate, or both the magnitudes of the inverse time constants will be _very small_.
Thus, even though one of them is negative
// === page 129 ===
in cases where $C_1$ is less than zero, it is only slightly so, meaning that the amplitude of the oscillations, while it does indeed grow with time, does so at a _much slower rate_ than would be the case if the rocket were spinning more slowly or not spinning at all.
It is therefore entirely possible that, if the rocket is spinning with sufficient rapidity, the rate at which the deflection of the model from its intended flight path direction grows after it is once disturbed from equilibrium will be so slight that no appreciable instability will be evident during the entire upward flight.
Once apex is reached and the recovery system is activated, of course, the stability question becomes irrelevant.
If the spinning of the rocket is capable of holding it reasonably close to its proper attitude during the handful of seconds it takes to reach its maximum altitude it will have accomplished its purpose --- and this, as we know from experience, is in fact the case.

Secondly, the presence of a rapid spin rate causes the _angular momentum_ of the rocket to be appreciable.
Angular momentum, like linear momentum, is a vector quantity which can be resolved into components by the methods of trigonometry.
If this is done we find that the Z-component of a rocket's angular momentum is just $I_R omega_z$; a rocket which is not rolling at all thus has no Z-component of angular momentum, and in fact if it is flying straight and true it has no angular momentum at all.
Now the effect of any disturbing moment on the model is to change its angular momentum: if it is a yaw disturbance it will impart an X-component of angular momentum, while if it is a pitch disturbance it will give rise to a Y-component.
// === page 130 ===
If the rocket is not spinning at all, the components of angular momentum imparted by disturbances will constitute _all_ the angular momentum the rocket has after any given disturbance.
If it _is_ spinning, however, the disturbance-imparted components of angular momentum are only _added vectorially_ to the Z-component which is already present.
What this means is that _a disturbance of a given strength will have less effect on a spinning rocket than on one which is not spinning_ because the change in angular momentum it imparts is of less importance to the spinning than to the non-spinning vehicle.
The practical consequence of all this is that the _initial amplitudes_ of the roll-coupled motion due to any given disturbance will be _less than_ those of the decoupled response associated with that same disturbance (you can prove this to yourself by taking a representative disturbance and calculating its effect on both a rolling and a non-rolling rocket).
Not only, therefore, does the angular displacement of a rapidly-spinning, unstable rocket increase very slowly after a disturbance is encountered, but the initial displacement produced by that disturbance is very slight.

In addition, the kind of physical phenomena that produce transient disturbances in model rockets generally tend to be evenly distributed about the rocket's longitudinal axis.
That is, it is just as likely that a step or impulse will be encountered in one direction as it is that it will be encountered in _any other direction_.
This being the case, it is rather likely that a rocket having encountered one disturbance will soon encounter another that cancels its effect --- _if_ the rocket has not diverged too far from its intended flight direction by that time.
If the
// === page 131 ===
rocket is unstable and is not spinning at all, the first disturbance it encounters will send it head over heels in a tiny fraction of a second, so this “averaging” effect will be no help at all.
If it is spinning rapidly enough, though, it will still be nearly enough “on course” when the second disturbance hits to take advantage of its ameliorating influence.
A rapid roll rate makes a rocket “sluggish” in its rotational behavior, allowing it to respond more nearly to the _time average_ of disturbances than to the individual disturbances themselves --- and since the time average is generally much less than any one individual disturbance, this is greatly to the rocket's advantage.

Finally, the presence of roll turns all disturbances due to imperfections in the rocket itself into sinusoidal forcing at the roll frequency, as mentioned in Section 3.2.4.
You will soon see how important this is if you examine equation (68b) and imagine $C_1$ to be a negative number, for if $C_1$ is negative then $(-C_1)$ must be positive.
This means that the quantity $[omega_z^2 (I_L + I_R) - C_1]$ will always be greater than $(-C_1)$ alone, which in turn means that _the amplitude of the response will decrease uniformly as the roll rate increases from zero to infinity: an unstable rocket cannot experience resonance._
To impart a rapid roll rate to an unstable rocket is thus to render the effect of a large class of disturbances upon it inconsequential.

So we see that the list of benefits available to statically unstable rockets through the mechanism of roll is impressive after all.
The net effect of all of them taken together produces a condition that _looks_ enough and _works_ enough like stability that the use of the term “roll stabilization” is really not altogether unjustified.
// === page 132 ===
== Analytical Determination of the Dynamic Parameters <sec:2-4>

The results of Section 3 have shown that it is possible to calculate the response of any model rocket to any in-flight disturbance if the values of certain quantities which characterize the rocket and the nature of the motion at the beginning of the observation are known.
Initial conditions, of course, vary from disturbance to disturbance; they are generally chosen to have any arbitrary values which insure that the response will remain within the range of validity of the linearized theory when doing actual calculations.
The quantities of really _fundamental_ importance to dynamic response
// === page 133 ===
are those which characterize the rocket itself, the so-called _dynamic parameters_: $C_1$, $C_2$, $I_L$, $I_R$, and $omega_z$.
Since the formulae which describe the response of a rocket to a given disturbance depend on these quantities, you _must know_ them in order to perform any actual numerical calculations.
How, then, does one determine their values?

There are two broad classes of techniques for performing such determinations: the _analytical_ method, in which basic considerations of mathematical physics are used to compute the dynamic parameters from a knowledge of the rocket's size, shape, and mass distribution, and the _experimental_ method, in which the dynamic parameters are determined from observations of the dynamic responses of actual vehicles.
The former of these two will be presented in this section, the latter in Section 5.

The analytical method has a distinct advantage in that, by its use, a rocket design can be completely evaluated (and altered if necessary) before construction is started.
Of course, it also involves the use of a large number of calculations, some of them based on approximations which only a human being (not a computer) has the judgment to make.
I would therefore recommend that the reader pay the most careful attention to the development which follows.
If you failed to understand the derivations in Section 3 you can still have recourse to computer-generated solutions, but these will be of no use to you if you cannot tell the parameters of your rocket.
A thorough comprehension of the following presentation _is_ essential to a complete knowledge of the factors which influence the design of model rockets.

=== Normal Force Coefficients and Center of Pressure: The Barrowman Method <sec:2-4.1>
// === page 134 ===
In March, 1967, James S. Barrowman of the National Aeronautics and Space Administration completed a remarkable document entitled _The Practical Calculation of the Aerodynamic Characteristics of Slender Finned Vehicles_.
Submitted as his Master's thesis to the School of Engineering and Architecture of the Catholic University of America, the report included, among other things, a method of calculating the aerodynamic forces on a streamlined, axially symmetrical body flying at velocities less than that of sound and subjected to small pitching and yawing deflections.
Such calculations can be used to determine the location of the center of pressure of a model rocket, the value of its corrective moment coefficient, and the value of its damping moment coefficient.
Additional applications of Barrowman's work enable the designer to determine the roll rate induced by canting the fins of his rocket a given amount at any given airspeed.

Barrowman's method is based on the concept of the _normal force coefficient_, $C_N_alpha$, a dimensionless number dependent upon the shape of the rocket which permits the calculation of the force acting in a direction perpendicular to the rocket's longitudinal axis whenever it is displaced from the direction of the relative airstream by some “angle of attack” (a pitching or yawing angle).
The equation by which this is accomplished is

$! N = C_N_alpha rho / 2 A_r V^2 alpha $

where $N$ = normal force

$rho$ = mass density of air

$V$ = airspeed of rocket
// === page 135 ===
$A_r$ = reference area, a scaling factor used to separate information regarding the rocket's size from the normal force coefficient.
Barrowman uses the cross sectional area of the body tube at the base of the nosecone as his reference area, and I will follow his convention.

$alpha$ = angle of attack in radians

Throughout the rest of this treatment I am going to be using the “centimeter-gram-second”, or CGS system of physical units.
This means that all lengths or coordinate values will be considered as given in centimeters, all areas will be considered to be expressed in square centimeters, all volumes will be considered to be given in cubic centimeters, all masses in grams, all forces in dynes, and all measurements of time in seconds.
Those readers unfamiliar with CGS and other metric systems of units should consult a physics text or mathematical handbook for the appropriate conversion factors between English and metric units.
The density of the Earth's atmosphere at sea level is, in CGS units,

$! rho = #num("1.225e-3") " grams"/"cm"""^3 $

so that the value of the force acting on a deflected rocket is given numerically by

$! N = #num("0.6125e-3") C_N_alpha A_r V^2 alpha " dynes" $

Now the normal force coefficient of the rocket considered as a whole is the sum of the normal force coefficients of the individual components of which it is composed: nosecone, body sections, adapters (if any), and fins.
Each part of the rocket
// === page 136 ===
is thus considered to provide a portion of the total normal force, and this portion is considered to act at a point on the component called its _center of pressure_ (c.p.).
The Barrowman method uses this technique of sectionalized analysis, together with the theory of moments, to derive the total normal force coefficient and center of pressure of the complete rocket.

Figure 32 illustrates the most general type of model rocket to which Barrowman analysis is applicable and the coordinate system used in performing the calculations.
Those readers who have some familiarity with Newtonian mechanics will recognize that the moments due to the normal force components are being taken about the nose of the rocket by such an arrangement.
The tip of the nose is considered to be $Z = 0$ and the value of the coordinate $Z$ increases as we move from the nose toward the tail of the rocket.
The rocket itself may have a nosecone, conical shoulder, conical boattail, body sections of constant diameter, and any number of fins (3 or greater) spaced symmetrically about the centerline.
The particular equations presented here, however, will be such that the number of fins must be either three or four since there is no particular reason to use any other number.
In addition to being axially symmetrical, the rocket must be relatively slender with a smoothly tapered nose, must be flying subsonically (in the low subsonic region below about #qty(200, "m/s")), must contain no abruptly-tapered sections, must not be deflected to an angle of attack greater than #qty(0.2, "rad"), must have fins that are virtually flat plates, and must not be subject to excessive deflections (bending) of its structure under loading conditions encountered in flight.

// === page 137 ===
#figure(
  image("/assets/figures-original/fig2-32.png"),
  caption: [Notation and longitudinal coordinate system used in the Barrowman method of finding the center of pressure of a model rocket.]
) <fig:2-32>

#figure(
  image("/assets/figures-original/fig2-33.png"),
  caption: [Center of pressure locations for some common nose shapes.]
) <fig:2-33>
// === page 138 ===
Under these conditions it can be shown that the normal force coefficient of the nose cone is independent of its shape, having the value 2.0 for all shapes which meet the assumptions of the analysis:

#eqn("79")[$ (C_N_alpha)_n = 2.0 $] <eq:2-79>

The location of the nose center of pressure is found by specialization of a more general relationship determined in Barrowman's paper: to determine the location of the C.P. of any axially symmetrical section of the rocket (nose, shoulder, or boattail) first compute the volume enclosed by its surface.
Then divide this volume by the area of the base (i.e., the cross-sectional area of the component at its greatest diameter).
The result of this division will have the units of _length_ (centimeters, in CGS units).
Starting from the position of the base, travel a distance equal to this length in the direction of the component's taper, and the point you will locate in this manner is the component's center of pressure.
You can see that, in order to give an actual formula for the location of the C.P. of such a part, we must have a part whose _volume_ is computable by some known geometrical equation.
The volume of unusually-curved components for which closed-form volume equations do not exist must be computed by immersing the part in question in liquid contained in a graduated cylinder.
Many nose cone shapes, however, closely approximate geometrical forms of known volume and @fig:2-33 lists the C.P. locations of four such shapes: conical, ogival, paraboloidal, and ellipsoidal.
Note that center of pressure coordinates are identified by a superscript
// === page 139 ===
bar, and also that a hemispherical nose is a special case of the ellipsoidal class, with its radius equal to its length.
The listings of @fig:2-33 are repeated below for reference:

#eqn("80a")[$ overline(Z)_n = 2/3 L quad "    (conical nose)" $] <eq:2-80a>

#eqn("80b")[$ overline(Z)_n = .466 L quad "    (tangent ogive nose)" $] <eq:2-80b>

#eqn("80c")[$ overline(Z)_n = 1/2 L quad "    (paraboloidal nose)" $] <eq:2-80c>

#eqn("80d")[$ overline(Z)_n = 1/3 L quad "    (ellipsoidal nose)" $] <eq:2-80d>

The notation used in determining the normal force coefficient and C.P. location of a conical shoulder is given in @fig:2-34.
The normal force coefficient of _any_ shoulder, whether or not it is conical, is given by

#eqn("81")[$ (C_N_alpha)_S = 2 [(r_2/r_r)^2 - (r_1/r_r)^2] $] <eq:2-81>

The conical form is, however, by far the most commonly used and the following equation for the C.P. location is valid _only_ for the conical configuration:

#eqn("82")[$ overline(Z)_(C S) = Z_1 + L [2/3 - 1/3 r_1/r_2 (r_1/r_2 + 1)] $] <eq:2-82>

@fig:2-35 illustrates the notation used in finding the normal force coefficient and C.P. of a conical boattail.
The normal force coefficient equation is identical to that used in computing the normal force coefficient of a shoulder:

#eqn("83")[$ (C_N_alpha)_B = 2 [(r_2/r_r)^2 - (r_1/r_r)^2] $] <eq:2-83>

Note, however, that in this case $r_2$ is _smaller_ than $r_1$, meaning
// === page 140 ===
#figure(
  image("/assets/figures-original/fig2-34.png"),
  caption: [Notation used in determining the normal force coefficient and center of pressure location of a conical shoulder. $Z_1$ denotes the distance from the tip of the nose to the forward end of the shoulder, while $overline(Z)_(C S)$ is the distance from the tip of the nose to the center of pressure of the shoulder.]
) <fig:2-34>

#figure(
  image("/assets/figures-original/fig2-35.png"),
  caption: [Notation used in determining the normal force coefficient and center of pressure location of a conical boattail. Again, $Z_1$ is the distance from the tip of the nose to the forward end of the boattail; $overline(Z)_(C B)$ is the distance from the nose tip to the boattail center of pressure.]
) <fig:2-35>
// === page 141 ===
that the value of $(C_N_alpha)_B$ is negative: a conical boattail experiences a suction force when the rocket of which it is a part is yawed in a moving airstream.
It follows that a boattail at the extreme after end of a rocket has a destabilizing effect, and any rocket incorporating such a device requires slightly larger fins than one which does not.
The center of pressure location of a conical boattail is given by

#eqn("84")[$ overline(Z)_(C B) = Z_1 + L/3 [1 + r_2/r_1 (r_2/r_1 + 1)] $] <eq:2-84>

Body tube sections of constant diameter exhibit no measurable normal force coefficient at zero angle of attack, and in fact produce no substantial normal force at all for angles of attack less than about 0.2 radian.
For this reason body tube sections are omitted from the equations of Barrowman analysis.

@fig:2-36 shows the system of notation used in determining the normal force coefficient and center of pressure location of a fin or set of fins.
Strictly speaking, the Barrowman method is applicable only to fins of the form shown in @fig:2-36, but in practical applications it is perfectly permissible to approximate a more complex fin shape by that shown in @fig:2-36.
As long as the lateral area of the hypothetical approximation is identical to that of the actual fin, the numerical results obtained from the Barrowman analysis will be very nearly correct.
If the approximate fin has _less_ area than the true fin, the results will be conservative, while if it has _more_ area than the true fin they will be overly optimistic.
This latter condition is dangerous and should be avoided.

The normal force coefficient of a single fin is given by
// === page 142 ===
#figure(
  image("/assets/figures-original/fig2-36.png"),
  caption: [Notation used in determining the normal force coefficient and center of pressure location of single fins and symmetrical fin assemblies. $Z_T$ is the distance from the tip of the nose to the intersection of the fin root and leading edge; $overline(Z)_(T(B))$ is the distance from the nose tip to the center of pressure of the fin assembly. The definition of $A R$, the _aspect ratio_ of a single fin, is also given.]
) <fig:2-36>
// === page 143 ===
#eqn("85")[$ (C_N_alpha)_1 = (A R ((c_r + c_t)/r_r) (s/r_r))/(2 + sqrt(4 + (A R/(s/r_r))^2)) $] <eq:2-85>

while that of a complete set of $N$ fins, where $N$ must be either three or four, is

#eqn("86")[$ (C_N_alpha)_T = (N A R ((c_r + c_t)/(2 r_r)) (s/r_r))/(2 + sqrt(4 + (A R/(s/r_r))^2)) $] <eq:2-86>

The airflow about the fins, however, is disturbed by the presence of the body with the result that the effective normal force coefficient of a set of fins is not equal to the expression given in Eq. #eqref(<eq:2-86>).
The influence of the body is accounted for by postulating an "interference coefficient" $K_(T(B))$ by which Eq. #eqref(<eq:2-86>) is to be multiplied to obtain the effective value of the normal force coefficient.
If we let

$! tau = (s + r_t)/r_t $

then the value of the interference coefficient for three- and four-finned configurations is given by

#eqn("87")[$ K_(T(B)) = 1 + 1/tau $] <eq:2-87>

so that the applicable value of the normal force coefficient is

#eqn("88")[$ (C_N_alpha)_(T(B)) = K_(T(B)) (C_N_alpha)_T $] <eq:2-88>

The longitudinal position of the C.P. of any one fin (which is also equal to the longitudinal position of the C.P. of the
// === page 144 ===
entire fin assembly) is computed according to

#eqn("89")[$ overline(Z)_T = Z_T + x_t/3 [(c_r + 2 c_t)/(c_r + c_t)] + 1/6 [c_r + c_t - (c_r c_t)/(c_r + c_t)] $] <eq:2-89>

while the radial position of the C.P. of an individual fin is

#eqn("90")[$ overline(Y)_T = r_t + s/3 [(c_r + 2 c_t)/(c_r + c_t)] $] <eq:2-90>

The C.P. of any radially-symmetrical set of three or more fins, of course, lies on the centerline of the rocket and thus has a radial coordinate of zero.

Having thus determined the normal force coefficients and longitudinal center of pressure locations of all applicable components, we are now in a position to compute the normal force coefficient of the complete rocket and the C.P. location of the vehicle considered as a whole.
For the total normal force coefficient we have

#eqn("91")[$ C_N_alpha = (C_N_alpha)_n + (C_N_alpha)_S + (C_N_alpha)_B + (C_N_alpha)_(T(B)) $] <eq:2-91>

while the C.P. location is given by

#eqn("92")[$ overline(Z) = ((C_N_alpha)_n overline(Z)_n + (C_N_alpha)_S overline(Z)_(C S) + (C_N_alpha)_B overline(Z)_(C B) + (C_N_alpha)_(T(B)) overline(Z)_T)/C_N_alpha $] <eq:2-92>

These last two are the most general forms of the Barrowman equations in that they account for the presence of conical shoulders and boattails.
Not all rockets have such components, but the equations are easily altered to apply to those that do not by omitting the terms due to the shoulder, the boattail, or both.

=== Locating the Center of Gravity <sec:2-4.2>
// === page 145 ===
In order to compute the static stability margin, corrective and damping moment coefficients, and moments of inertia of a model rocket it is necessary to determine the location of its center of gravity.
This is done by a method of moments very similar to that of the Barrowman equations, except that here we work with moments of mass rather than moments of pressure forces.

If you have a complete rocket which has already been built, of course, it is a simple matter to balance the flight-ready vehicle (with payload, engine, and recovery system in place) on a cord or knife-edged object in order to find the C.G. directly, for the C.G. is defined as the balance point.
We are concerned here, though, with _designing_ model rockets and must therefore have some means of predicting the C.G. location of a rocket _before_ construction is begun.
In order to do this precisely you must know the exact mass and the balance point of each component --- nosecone, body tube, shoulder and boattail (if any), engine(s), fin assembly, and recovery system --- of which the rocket is comprised.
The payload, if any, must also be taken into account.

The notation used in computing the C.G. location is illustrated in @fig:2-37.
Note that _moments_ are again taken about the tip of the nose, and that the longitudinal coordinate increases as we move from the nose toward the tail, but the _name_ of this coordinate has been changed from $Z$ to $W$ to avoid the use of elaborate subscript notation to distinguish between centers of gravity and centers of pressure.
The masses of certain of the components --- lengths of body tubing, rocket engines, shoulders,
// === page 146 ===
#figure(
  image("/assets/figures-original/fig2-37.png"),
  caption: [Notation and longitudinal coordinate system used in determining the center of gravity location of a model rocket. For the sake of clarity, not all components have been considered in this drawing; the two constant-diameter tube sections forward of the conical boattail, for instance, have been omitted and the tail section --- tube, engine, and fins --- has been considered as a unit.]
) <fig:2-37>
// === page 147 ===
boattails, nosecones, and the standard National Association of Rocketry payload, for instance --- can be determined from information given by the manufacturer, although you will have to take care to express weights given in ounces as masses given in grams by multiplying them by the factor 28.35.
The masses of fins, fully-rigged recovery systems, and nonstandard payloads and components, however, must be determined by weighing on a laboratory gram balance.
The C.G. of each individual component can be determined by string or knife-edge balancing, except for those parts of the rocket which have not yet been made or cut to length, such as the body tube and fins.
The C.G. of a uniform body tube is, of course, its geometrical center.
The C.G. of a proposed set of fins can be found by cutting a pair of the proposed design, joined root to root, out of cardboard and balancing the fin set thus obtained on a knife-edge held spanwise.
The weight of a fin is found by multiplying its area by the weight per unit area of the balsa sheet or other material of which it is composed.
The weight per unit area of fin material, in turn, can be determined by weighing a sample sheet of fin material whose area is known (such as a complete three-by-thirty-six inch sheet of balsa, which has an area of 698 square centimeters) on a laboratory gram balance and dividing the weight thus obtained by the area of the sheet.
To obtain conservative estimates you should completely fill and paint such balsa sample sheets and also use the hardest sheet of balsa you can find.
This is because painting adds significantly to the weight of the fins and the weight of balsa itself varies greatly from piece to piece, being the greatest for the hardest material.
C.G. estimates
// === page 148 ===
should also be made on the basis of the most powerful (that is, heaviest) engine(s) with which it is intended that the rocket be flown.

Once the mass and C.G. location of each individual component have been determined, the total mass at liftoff and C.G. of the complete rocket at liftoff can be calculated as follows:

#eqn("93")[$ M = M_n + M_s + M_p + M_b + M_r + M_t + M_e + M_f $] <eq:2-93>

where $M_n$ = mass of nosecone \
$M_s$ = mass of shoulder \
$M_p$ = mass of payload and payload section of tube \
$M_b$ = mass of boattail \
$M_r$ = mass of fully rigged and packed recovery system \
$M_t$ = mass of body tube \
$M_e$ = mass of engine \
$M_f$ = mass of fins

#eqn("94")[$ overline(W) = (M_n overline(W)_n + M_s overline(W)_s + M_p overline(W)_p + M_b overline(W)_b + M_r overline(W)_r + M_t overline(W)_t + M_e overline(W)_e + M_f overline(W)_f)/M $] <eq:2-94>

As in the Barrowman calculations, any component which a given rocket design does not contain can simply be omitted from the equations.
Unlike the Barrowman equations, however, the C.G. equations _always_ contain nonzero contributions from the lengths of body tubing employed in building the rocket.

Now it so happens that in the vast majority of actual model designs the location of the C.G. is very largely determined by the mass properties and locations of the nose, payload, body and engine alone.
Because of this it is often possible to get
// === page 149 ===
a very good estimate of the C.G. location of the finished rocket by performing a "preassembly balancing" --- cutting the body tube to length, inserting engine and payload, and fitting the nosecone; then simply balancing the partly-completed rocket thus obtained.
If your design is relatively standard or intended only for sport flying you can save a lot of work by measuring the C.G. location in this way, but a knowledge of the analytical method of Eq. #eqref(<eq:2-93>) and Eq. #eqref(<eq:2-94>) is invaluable when working to high tolerances, doing competition work, or experimenting with unusual designs.

=== The Corrective Moment Coefficient <sec:2-4.3>

The results of @sec:2-4.1 and @sec:2-4.2 enable the calculation of the dynamic parameter $C_1$ as follows:

#eqn("95")[$ C_1 = 1/2 V^2 A_r C_N_alpha [overline(Z) - overline(W)] $] <eq:2-95>

The numerical value of $C_1$ in CGS units is given by

#eqn("96")[$ C_1 = (0.6125 times 10^(-3)) V^2 A_r C_N_alpha [overline(Z) - overline(W)] quad "dyne-centimeters" $] <eq:2-96>

Note that $overline(W)$ must be _smaller_ than $overline(Z)$ for $C_1$ to be a positive number; this is just the equation's way of telling us that the C.P. must lie _behind_ the C.G. for the rocket to be stable.
The distance $(overline(Z) - overline(W))$ is referred to as the _static stability margin_ of the rocket.
The static stability margin is often "nondimensionalized" by dividing it by the maximum body diameter of the rocket.
The resulting quantity is some multiple of the rocket's maximum diameter, or "caliber", and it is thus standard practice to refer to the static stability margin of a given rocket in calibers.
The notation associated with computing $C_1$ and the static stability
// === page 150 ===
margin is explained in @fig:2-38.

=== The Damping Moment Coefficient <sec:2-4.4>

The dynamic parameter $C_2$ is the sum of two components, one of which is aerodynamic in origin, the other propulsive.
The aerodynamic contribution to damping has been obtained by Barrowman as

#eqn("97")[$ C_(2A) = rho/2 V A_r { (C_N_alpha)_(T(B)) [overline(Z)_T - overline(W)]^2 + (C_N_alpha)_n [overline(Z)_n - overline(W)]^2 + (C_N_alpha)_S [overline(Z)_(C S) - overline(W)]^2 + (C_N_alpha)_B [overline(Z)_(C B) - overline(W)]^2 } $] <eq:2-97>

or which the CGS numerical result is

#eqn("98")[$ C_(2A) = (0.6125 times 10^(-3)) V A_r { (C_N_alpha)_(T(B)) [overline(Z)_T - overline(W)]^2 + (C_N_alpha)_n [overline(Z)_n - overline(W)]^2 + (C_N_alpha)_S [overline(Z)_(C S) - overline(W)]^2 + (C_N_alpha)_B [overline(Z)_(C B) - overline(W)]^2 } quad "dyne-centimeter-seconds" $] <eq:2-98>

As in @sec:2-4.1, any component which a given rocket does not possess is simply omitted from the calculation.

During the time in which the rocket motor is firing there is an additional contribution to the damping moment arising from the expulsion of mass from the nozzle.
If the nozzle exit is considered to be located a distance $L_(n e)$ from the tip of the nose this propulsive damping moment coefficient is given by

#eqn("99")[$ C_(2R) = dot(m) [L_(n e) - overline(W)]^2 quad "dyne-centimeter-seconds" $] <eq:2-99>

where $dot(m)$ = rate of mass expulsion from the nozzle, grams/second.
The phenomenon of damping due to rocket thrust is generally referred to as "jet damping".
Readers desiring to explore the topic further should consult _The Exterior Ballistics of Rockets,_

// === page 151 ===
by Davis, Follin, and Blitzer.
This text, while highly mathematical in parts, contains an excellent development of the physics of propulsive damping.

You should notice that $C_(2R)$ is not generally constant during the time of thrusting, since $dot(m)$ depends on the motor's thrust $F$ and exhaust velocity $V_e$ according to

$! dot(m) = F / V_e $

Both $F$ and $V_e$ vary with time during the burning of the motor, so that the determination of $dot(m)$ with precision can be quite difficult.
Fortunately, though, most model rocket motors of the end-burning type have a thrust and exhaust velocity that are virtually constant over much of the burning time.
A rough average of the mass expulsion rate may then be computed by dividing the mass of propellant (call it $m_p$) contained in the motor before ignition by the duration of burning, $t_b$:

$! dot(m) = m_p / t_b $

Whenever this approximation is valid the contribution of jet damping to the damping moment coefficient is

#eqn("100")[$ C_(2R) = m_p / t_b (L_(n e) - overline(W))^2 $] <eq:2-100>

The value of the damping moment coefficient during the time the rocket motor is thrusting is thus

#eqn("101a")[$ C_2 = C_(2A) + C_(2R) $] <eq:2-101a>
// === page 152 ===
#figure(
  image("/assets/figures-original/fig2-38.png"),
  caption: [Notation used in computing corrective moment coefficient and static stability margin.]
) <fig:2-38>
// === page 153 ===
and the damping moment coefficient during the coasting phase of flight is given by

#eqn("101b")[$ C_2 = C_(2A) $] <eq:2-101b>

@fig:2-39 and @fig:2-40 illustrate the notation and procedure used in computing the aerodynamic and propulsive contributions to the damping moment coefficient.

=== The Longitudinal Moment of Inertia <sec:2-4.5>

A model rocket consists primarily of coaxial, circular cylindrical objects, of which some --- such as the propellant grain, solid bulkheads, and NAR standard payload (if any) --- are solid throughout and others --- the body tube and motor casing, for example --- are hollow.
The nose cone, shoulders, and boattails can be of any radially symmetrical configuration, while there is less restriction on the geometry of fins and most models carry some small, dense, irregularly-shaped objects such as the bits of lead which are sometimes used as nose weights.
Each component of the rocket contributes in some measure, depending on its mass, shape, and location, to the moments of inertia, and the inertial properties of the completed rocket are computed by determining each such contribution and adding all the contributions together.

The contribution of any extended body to the longitudinal moment of inertia is equal to its mass multiplied by the _square_ of the longitudinal distance between its C.G. and the C.G. of the complete rocket, _plus_ its moment of inertia measured about a transverse axis passing through its own C.G.
The contribution to $I_L$ of any extended body (call it $o$) may thus be written
// === page 154 ===
#figure(
  image("/assets/figures-original/fig2-39.png"),
  caption: [Notation used in computing aerodynamic damping moment coefficient.]
) <fig:2-39>

#figure(
  image("/assets/figures-original/fig2-40.png"),
  caption: [Notation used in computing propulsive damping moment coefficient.]
) <fig:2-40>
// === page 155 ===
#eqn("102")[$ I_(L o) = M_o [overline(W) - overline(W)_o]^2 + I_(L o)' $] <eq:2-102>

where $I_(L o)$ denotes the actual contribution of $o$ to the longitudinal moment of inertia of the rocket and $I_(L o)'$ refers to the object's longitudinal moment of inertia with respect to its own C.G., which is located a distance $overline(W)_o$ from the tip of the nose.

In particular, the contribution of a solid, right, circular cylindrical object of uniform density to the longitudinal moment of inertia is given by

#eqn("103a")[$ I_(L c s) = M_c { [overline(W) - overline(W)_c]^2 + R^2 / 4 + L^2 / 12 } $] <eq:2-103a>

where $M_c$ = mass of cylinder

$L$ = length of cylinder

$R$ = radius of cylinder

$overline(W)_c$ = location of cylinder's C.G. (midpoint) reckoned as distance back from tip of nose

while the contribution due to a _hollow_ cylindrical object of outer radius $R_o$, inner radius $R_i$, is

#eqn("103b")[$ I_(L c h) = M_c { [overline(W) - overline(W)_c]^2 + (R_o^2 + R_i^2) / 4 + L^2 / 12 } $] <eq:2-103b>

There also exist analytical expressions for the contributions of various nose cone shapes, shoulders, and boattails, and (in principle, at least) the contribution of any object whatsoever, regardless of shape or density properties, is computable by the methods of _integral calculus_.
Unfortunately, however, the majority of algebraic solutions obtainable by such techniques are so long and complex that they are utterly impractical to work with.
// === page 156 ===
The best course for the designer in this situation is to resort to an approximate technique for taking these components into account.
Such a procedure is the "point-mass approximation", in which all the mass of a given object is considered to be concentrated at its own C.G.
This deprives the object in question of the property of extension and causes the term $I_(L o)'$ in Eq. #eqref(<eq:2-102>) to become zero; the point-mass approximation thus always results in an _underestimate_ of the component's inertial contribution, since it ignores the object's mass distribution.
The point-mass assumption is most nearly valid when the component under consideration is far from the C.G. of the complete rocket in comparison with its own dimensions; one thus often hears the method referred to as computing the inertial contribution of a "remote object".
As it turns out, nose cones, nose weights, and payloads usually obey the approximation rather well but the technique is not as good when applied to shoulders, boattails, and fins.
Some designers prefer to replace the distance between the component C.G. and the rocket C.G. by the distance from the rocket C.G. to the _most remote_ point of the component (the trailing edge of the fins, for example) in order to increase the magnitude of the point-mass estimate in cases where its accuracy is questionable.
@fig:2-41 summarizes the various notations used to compute the contributions of some representative components to the longitudinal moment of inertia of a hypothetical rocket.

The longitudinal moment of inertia of any given component about a transverse axis through its own C.G. can also be _measured_ experimentally by the use of the torsion-wire method, the same
// === page 157 ===
#figure(
  image("/assets/figures-original/fig2-41.png"),
  caption: [Examples of the notation used in computing contributions to the longitudinal moment of inertia. An object subject to the point-mass approximation (nosecone), a solid cylindrical component (NAR payload), and a hollow cylindrical component (engine casing) are illustrated.]
) <fig:2-41>
// === page 158 ===
technique used to determine the inertial properties of a completed, flight-ready rocket (to be discussed in detail in @sec:2-5).
The diameter of the wire used for the measurement of moments of inertia of some of the smaller components, however, will need to be smaller than that used for full-vehicle experiments.
In some cases it may have to be as small as #qty(0.005, "in") or even #qty(0.003, "in").

Once the contribution to $I_L$ of each component of the rocket has been determined, the longitudinal moment of inertia of the assembled vehicle can be computed by taking the sum of all the contributions.
The number of contributions will vary from rocket to rocket, and in addition most designers use their own judgment in selecting only those components large enough and/or far enough from the C.G. of the complete rocket to include in the computations.
The minimum set of components necessary to take into consideration generally consists of body tube, engine, nose cone, payload (if any), and fins.
Shoulders, boattails, and substantial bulkheads should also be included if the rocket has such components, but lesser items such as screw eyes, shock cords, streamers, and launch lugs are commonly omitted since their contributions are miniscule.
Because the number and nature of inertial contributions varies so widely from rocket to rocket, a mathematical shorthand called "summation notation" is usually used to express the equation for the longitudinal moment of inertia as follows:

#eqn("104")[$ I_L = sum_i I_(L i) $] <eq:2-104>

This symbolism, literally translated into English, means simply "the longitudinal moment of inertia of the entire rocket is
// === page 159 ===
equal to the sum of the contributions to the longitudinal moment of inertia from all the components of the rocket".
As you can see, summation notation saves a great deal of writing.
It could equally as well have been applied to a number of other equations in this section; this I did not do, however, since I feel that the presence of examples of the explicit form of writing out summations aids in understanding the nature and purpose of summation notation.

=== The Radial Moment of Inertia <sec:2-4.6>

The radial moment of inertia of an assembled rocket is also predicted by summing the contributions due to all its components.
The contribution of a solid cylindrical component of mass $M_c$ and radius $R$ to this quantity is given by

#eqn("105a")[$ I_(R c s) = 1 / 2 M_c R^2 $] <eq:2-105a>

while that of a hollow cylindrical component of inner radius $R_i$ and outer radius $R_o$ is

#eqn("105b")[$ I_(R c h) = 1 / 2 M_c [R_o^2 + R_i^2] $] <eq:2-105b>

The algebraic formulae for the radial moment of inertia contributions due to most nose cone shapes are, fortunately, much more tractable than in the case of longitudinal moment of inertia contributions.
A few of the more elementary ones are those for a conical nose,

#eqn("106")[$ I_(R n) = 3 / 10 M_n R^2 $] <eq:2-106>

and for an ellipsoidal or hemispherical nose,
// === page 160 ===
#eqn("107")[$ I_(R n) = 2 / 5 M_n R^2 $] <eq:2-107>

where, in each equation $M_n$ denotes the mass of the nose cone and $R$ its radius at the shoulder.

Fins are difficult to treat analytically in any great generality due to the great variety of planform shapes possible.
They cannot be ignored in computing the radial moment of inertia, despite the fact that their mass is often small, because it is also true that they extend farther from the centerline of the rocket than any other component.
Nor can the point-mass approximation be made, as the spanwise extent of a fin is of comparable magnitude to the distance between its C.G. and the model's centerline.
If, as when performing Barrowman calculations, however, we idealize the fin planform to a trapezoid, we can obtain a good approximation to the radial moment of inertia due to a thin, flat fin of uniform density in the form

#eqn("108a")[$ I_(R f) = { [(s + r_t)^3 - r_t^3] c_r / 3 - (c_r - c_t) / (4(s + r_t)) [(s + r_t)^4 - r_t^4] } M_f / A_f $] <eq:2-108a>

where $M_f$ = mass of fin

$A_f$ = lateral area of one side of fin

$r_t$ = radius of fin root from rocket centerline

$s$ = span of one fin

$c_r$ = root chord of fin

$c_t$ = tip chord of fin

It follows that the contribution of a tail assembly of $N$ identical fins, symmetrically arranged, is
// === page 161 ===
#eqn("108b")[$ I_(R t) = N I_(R f) $] <eq:2-108b>

The notation used in computing radial moment of inertia contributions of some representative components is shown in @fig:2-42.
Generally speaking, consideration of body tube, fins, engine, nosecone, and payload, shoulder, and boattail (if any) in the calculations will suffice to give an accurate prediction of the radial moment of inertia of the completed model.
As in the case of the longitudinal moment of inertia, the contribution of any given component can be determined experimentally by torsion wire.
Once all the contributions to $I_R$ from the various components have been determined, the radial moment of inertia of the assembled rocket can be calculated according to

#eqn("109")[$ I_R = sum_i I_(R i) $] <eq:2-109>

You should notice that moments of inertia, both longitudinal and radial, have units of gram-centimeters$""""^2$.

=== General Properties of the Parameters <sec:2-4.7>

Having derived expressions by which the various dynamic parameters may be computed, we are now in a position to make some observations concerning their general nature and properties.
We can, for instance, determine the physical dimensions of the various angular frequencies and time constants derived in the analyses of Section 3.
From Sections 4.1 through 4.6 we have that the units of $C_1$ are dyne-centimeters, those of $C_2$ are dyne-centimeter-seconds, and those of $I_L$ and $I_R$ are gram-centimeters$""""^2$.
The definitions of $C_1$ and $C_2$ from Section 2.2, however, indicate
// === page 162 ===
#figure(
  image("/assets/figures-original/fig2-42.png"),
  caption: [Examples of the notation used in computing contributions to the radial moment of inertia. An ellipsoidal nosecone, a solid cylindrical component (nosecone shoulder), a hollow cylindrical component (body tube), and a set of four fins are illustrated.]
) <fig:2-42>
// === page 163 ===
that the correct units of these parameters should be dyne-centimeters/radian for $C_1$ and dyne-centimeter-seconds/radian for $C_2$.
There is nothing inconsistent here, however, because radians are by definition dimensionless (that is, they have no physical units).
Their presence or absence thus cannot be detected in a dimensional analysis and one must remember to supply them whenever necessary in determining angular frequencies.

Both angular frequencies and time constants should be computed using units for the dynamic parameters as obtained from Sections 4.1 through 4.6, which do _not_ contain radians.
If this is done we obtain for any angular frequency the units (1/seconds).
To this we must supply radians, thereby obtaining the physically meaningful result that angular frequencies have units of radians/second.
Radians per second are thus the physical dimensions of $omega$, $omega_n$, $omega_1$, $omega_2$, $omega_f$, and $omega_z$.
Any inverse time constant ($D$, $D_1$, or $D_2$) will be found to have units of (1/seconds).
Radians should _not_ be supplied to this result.
Ordinary time constants (that is, $tau_1$ or $tau_2$) will turn out to have dimensions of seconds.
Initial amplitudes and phase angles, of course, are in radians.

The coupled and decoupled damping ratios, $zeta$ and $zeta_c$, will be found to be _dimensionless_; like normal force coefficients, they have no physical units at all.
Moreover, since $C_1$ varies as the _square_ of airspeed while $C_2$ varies _linearly_ with airspeed, you can see from equations (20) and (70) that neither damping ratio varies at all with airspeed.
_Damping ratio is therefore velocity-independent_ --- an enormously valuable property from the standpoint of analysis, for it means that the damping ratio (aside from small variations due to jet damping) of any given rocket will remain
// === page 164 ===
_constant throughout its flight even though the velocity of the rocket may vary by an order of magnitude or more._
It is then possible to define "acceptable" and "optimum" ranges of damping ratio which contribute to better flight characteristics, since the damping ratio can be designed into the model.
$zeta$ and $zeta_c$ are relationships among geometrical and mass properties of the rocket and are independent (within the linearized theory) of its aerodynamic environment.

== Experimental Determination of the Dynamic Parameters <sec:2-5>

Mathematical analysis is a powerful and elegant technique that enables the designer of model rockets to obtain all the necessary information concerning the properties of his model while it is still "on the drawing board".
Such analytical methods, however, are always based on approximations to the phenomena under consideration, for there invariably exist factors for which it is either impossible or impractical to account with absolute precision.
The value of an engineering approximation is based on the fact that the errors it introduces under normal conditions are small, while the analytical simplification it permits is considerable.
Even the most valuable of such approximations, though, is likely at one time or another to encounter some set of circumstances under which it becomes invalid.
The limitations of analysis, the questionable nature of certain of its approximations with respect to nonstandard designs, and the necessity to establish limits of operating conditions for the validity of the approximations make it essential that we have recourse to empirical measurement to supplement and check the results of analytical computation.
The subject matter of this section concerns itself with the

// === page 165 ===
experimental techniques by which such measurements may be obtained.

=== Moments of Inertia: The Torsion-Wire Experiment <sec:2-5.1>

The torsion-wire experiment is one of the standard techniques currently in use by professional industry for measuring the moments of inertia of such things as the rotative components of electric motors and turbomachinery and the indicating movements of various instruments.
The experiment is ideally suited to model rocket work, providing rapid, precise, and independent determinations of the longitudinal and radial moments of inertia.
The experimental apparatus can be put together in about twenty minutes at a cost that can be less than fifty cents, depending on the materials at hand, and the measurement can be made directly using the actual model in its ready-to-launch configuration without altering or damaging it in any way.

The basis of the measuring system is the torsion wire itself, a three-foot length of thin music wire.
Wire diameters in the range #qty(0.010, "in") to #qty(0.020, "in") are acceptable for most model rocket work, with the lower end of the range best suited to smaller rockets or radial moments of inertia, the upper end to larger rockets or longitudinal moments of inertia.
The last inch on each end of the torsion wire is bent over the center of a two-inch length of #qty(0.045, "in") music wire, then twisted to hold it tightly and soldered in place, forming a "T" fitting at each end of the wire.
These "T" configurations are the means by which the torsion wire is secured to the test rocket at one end and the mounting structure at the other.

@fig:2-43 shows a complete torsion wire system set up for measuring the moments of inertia of a model rocket.
// === page 166 ===
#figure(
  image("/assets/figures-original/fig2-43.png"),
  caption: [Measurement of moments of inertia using a torsion wire.
Illustration (a) shows a model rocket suspended in the position used for determining its longitudinal moment of inertia; (b) shows the mounting position used for a determination of the radial moment of inertia.]
) <fig:2-43>
// === page 167 ===
Illustration A demonstrates the correct method of mounting the rocket to obtain a measurement of its longitudinal moment of inertia, while illustration B shows the mounting configuration for measuring the radial moment of inertia.
The upper "T" fitting is clamped or otherwise fastened to an overhanging beam mount, which can be a simple two-by-four with its other end clamped to a shelf, a table, or any other structure that will allow the suspended rocket to clear the floor of the laboratory.
Torsion wire experiments should always be done indoors in order to minimize disturbances of the apparatus caused by stray air currents.

The lower "T" is strapped to the rocket or component whose moment of inertia is to be measured by means of drafting or masking tape.
The lighter the entire attachment assembly is, the better will be the accuracy of the measurement, and this may make some designers prefer to use a thinner crossbar and/or Scotch Magic Tape.
The use of Magic Tape requires a great deal of care, however, to avoid damaging the finish of the model when removing the tape after a test is completed.

In order to calibrate a newly-built torsion wire system a _reference standard_ is needed.
The reference standard must be some object having a simple shape and a known density or mass, so that its moment of inertia is computable by means of a simple algebraic formula.
One of the most convenient reference standards you can use is a half-inch aluminum rod about one foot long, suspended with its longitudinal axis parallel to the floor as in Figure 43A.
The rod's moment of inertia, designated $I_s$, is given by

#eqn("110")[$ I_s = M [ R^2 / 4 + L^2 / 12 ] quad "gram-centimeters"""^2 $] <eq:2-110>
// === page 168 ===
where $M$ = mass of rod in grams

$R$ = radius of rod in centimeters

$L$ = length of rod in centimeters

A diameter of one-half inch corresponds to a radius of #qty(0.635, "cm"); if such a rod is cut to a length of #qty(29.7, "cm") and is of aluminum alloy 6061 it will have a mass of #qty(101.8, "g") and therefore a moment of inertia of precisely #num("7500") gram-centimeters$""""^2$.
Reference standards of different values of $I_s$ may be prepared by using rods of different lengths, diameters, and materials, but you should find that the one described above is convenient for the majority of the measurements you will be making.

A timing device completes the equipment needed to perform the experiment.
An ordinary wristwatch with a sweep second hand will do for this purpose, but much better accuracy is obtainable from a stopwatch or an electric laboratory stopclock.
If a timing device accurate to a hundredth of a second is used, the experiment will yield values of moments of inertia which are repeatable to better than 2%.

A torsion-wire determination is performed by measuring the _period of torsional oscillation_ of the model and comparing it to that of the reference standard.
This means that the wire must first be calibrated by performing the experiment with the reference standard affixed to the wire as in Figure 43A.
The oscillations are started by twisting the wire between the fingers until the reference standard makes nearly one full revolution about the axis of the wire, then releasing it, taking care not to start the whole arrangement swinging like a pendulum in the process.
Upon being released the reference standard will begin
// === page 169 ===
to turn slowly about the wire axis, first in one direction, then the other, twisting the wire this way and that.
This is what is meant by the term "torsional oscillation".
The _period_ of the oscillation is the time in seconds taken for the suspended object to execute one complete _cycle_; that is, to twist from one extreme of the oscillation to the other _and back again_.
To increase the accuracy of the determination, you should measure _ten_ such periods in a single timing, starting the time when the reference standard is at one extreme of its oscillation and stopping it when the reference standard returns again to that position for the tenth time.
If the time thus measured is divided by ten, a much more accurate determination of the period will result than could be obtained by measuring a single cycle.
Denote the period of the reference standard by $T_s$ and keep a careful record of its value, for once you have obtained it you need never measure it again; the wire has been calibrated and the _known_ values $I_s$ and $T_s$ may be used in reducing data from any further experiments done with that particular wire.

To determine the moments of inertia of the model, remove the reference standard from the wire and affix the model as in Figure 43A for determining $I_L$ or as in Figure 43B for determining $I_R$.
In each configuration, the oscillations are started and the torsional period is measured just as in the case of the reference standard.
With most model rockets, torsion wires of diameters between #qty(0.010, "in") and #qty(0.020, "in") produce relatively slow oscillations which are easy to time with a high degree of accuracy and which are very lightly damped.
It should thus not be difficult to observe the oscillations of the model for
// === page 170 ===
a full ten cycles.

With the rocket mounted as in Figure 43A an oscillation period whose value I shall denote by $T_L$ will have been measured.
The longitudinal moment of inertia of the rocket can then be computed according to

#eqn("111")[$ I_L = I_s ( T_L / T_s )^2 $] <eq:2-111>

Similarly, when the model is mounted as in Figure 43B an oscillation period $T_R$ will result, from which the radial moment of inertia of the rocket can be calculated as

#eqn("112")[$ I_R = I_s ( T_R / T_s )^2 $] <eq:2-112>

=== The Corrective Moment Coefficient <sec:2-5.2>

The value of the corrective moment coefficient is determined by measuring the static angular deflection of the rocket produced by a known pitching moment.
This experiment, as well as those to be described in subsequent sections, requires a small wind tunnel --- one which has a test section whose transverse dimensions are at least twelve by twelve inches and which is capable of producing an airspeed of at least #qty(15, "m/s").
It would also be preferable if the airspeed were continuously variable, since this makes some of the experiments more convenient, but this feature is not essential.
I am not going to try to explicitly describe the construction of a wind tunnel here; the variety of types is considerable and any such discussion would require a complete book of its own.
Building such a device is a major project in itself, and most rocketeers would rather have recourse
// === page 171 ===
to a facility that already exists, such as those owned by some universities, NAR sections, and model rocket manufacturers.
Those readers who would like to build their own tunnels can find information on the subject in _Wind Tunnel Testing_, by Alan Pope (Second Edition, John Wiley and Sons, Inc., New York, 1954).
A reading of this comprehensive work should give you a good idea of the variety of wind tunnel types available and the nature of the design process involved in their planning.

The experiment to determine the corrective moment coefficient is performed using a moment balance and test rocket as shown in @fig:2-44.
The balance is basically a single-degree-of-freedom gimbal consisting of a pulley wheel attached to a steel shaft which runs through ball bearings to terminate in an aluminum plug fitting.
The test rocket is constructed in two sections, such that the forward section can be snugly slid onto one end of the plug fitting, the after section onto the other.
Because it is necessary to build the rocket in this way only a _design_ can be tested, not an actual rocket which is to be flown, but the arrangement has the advantage that it produces a minimal disturbance in the airflow.

That portion of the shaft on which the plug is mounted extends through a hole in the wall of the wind tunnel test section and out into the airstream, such that the plug is located approximately in the center of the test section.
The case is bolted to the side of the test section opposite the viewing area in order to hold the instrument in place.

The moment balance in @fig:2-44 is shown with a pointer-and-protractor device for indicating the angle of deflection.
// === page 172 ===
#figure(
  image("/assets/figures-original/fig2-44.png"),
  caption: [Experimental apparatus for determining the corrective moment coefficient.
The same instrument, with the pulley wheel, counterweight, and balance pan assembly removed, can be used for determining the damping moment coefficient.
Bolt holes are provided in the bearing support plate nearest the test rocket for mounting the apparatus on the wall of a wind tunnel test section.]
) <fig:2-44>
// === page 173 ===
This arrangement is perfectly adequate for static-deflection experiments; in the experiments described in later sections, though, where the rocket is set to oscillating, it will become desirable to _record_ the value of the angular deflection at any given time.
This can be done with motion pictures and in various other ways using the protractor system, but it is usually preferred to substitute some electrical device for measuring the angle and to feed its output into a chart recorder, which then automatically draws a graph of deflection versus time.

To generate the moment which will cause the rocket to assume an angle of pitch relative to the oncoming airstream it is necessary to apply a force tangential to the pulley wheel at its outer radius.
This is done by suspending a balance pan from a thin cord which has been wrapped around the pulley and adding known weights to the pan.
The balance pan itself must be suitably counterweighted so that there is no moment applied when there is no weight in the pan.

The experiment is prepared by adjusting the weights of the forward and after sections of the test rocket so that, when assembled on the plug with an engine installed, it balances when the airstream is off and there is no weight in the pan.
Under these conditions the shaft centerline passes through the C.G. of the rocket, so that free-flight conditions are being accurately simulated.

The airstream is then turned on and adjusted to some fixed velocity value which is not to be altered during the course of the experiment.
The model should come to rest facing directly into the oncoming wind, which in a good wind tunnel will coincide with the test
// === page 174 ===
section centerline.
If it fails to face into the wind, or turns tail-on to the wind, it is of course statically unstable and must be redesigned.
Assuming the model is facing the airstream properly, the last remaining preliminary step is to check the angle indicator and adjust it if necessary so that it reads zero.

The addition of weights to the pan can now be started, beginning with a unit weight that produces a small deflection (between $1 degree$ and $2 degree$), but which is an even quantity such as a single laboratory balance weight or simple combination thereof.
Record the mass, in grams, of the weight used and the exact deflection in degrees which it produced.
Then add another weight identical to the first and record the new deflection from the zero-degree line produced by the two acting together, making certain that all movement has subsided before you take a reading.
Continue adding weights in this manner, recording the deflection angle associated with each value of total mass in the pan, until you reach a point at which the rocket will no longer come to equilibrium and the slightest additional weight in the pan will cause the rocket/balance assembly to become unstable.
This will generally occur at some value of deflection angle between $12 degree$ and $18 degree$ and is due to the slope of the corrective moment curve becoming zero at that point (refer back to Figure 7 for an illustration of the corrective moment curve).

The experiment is now complete and data reduction can begin.
The first step here is to transform the units in which the data are expressed, so that angular deflections are given as radians and pitching moments as dyne-centimeters.
Deflections in
// === page 175 ===
degrees are converted to radian measure by dividing by 57.3; a moment in dyne-centimeters is computed by multiplying the mass (in grams) placed in the pan by 980 and then multiplying the result thus obtained by the radius of the pulley wheel in centimeters.
These procedures are illustrated in @fig:2-45.
The completed data reduction should provide a table listing each deflection in radians next to the moment required to produce it in dyne-centimeters.

The data points are then plotted on a graph in cartesian coordinates whose horizontal axis represents pitching angle in radians and whose vertical axis represents pitching moment in dyne-centimeters.
Such a plot is made by locating each point described by a coordinate pair in the table (a deflection and its associated moment) on the graph and marking it with a small "x" or dot, then drawing a smooth curve which, as nearly as possible, connects all the points.
Since experimental data normally contains some "scatter", it is more likely that your curve will be accurate if it is smooth than if it connects each and every point with all its neighbors.
The resulting graph is a representation of the first part of the curve in Figure 7: corrective moment as a function of angle of attack.
In order to compute $C_1$ from this graph, place a straightedge on it such that its edge is tangent to the curve at the intersection of the coordinate axes (the origin) and draw a line using the straightedge as a guide.
This is the graphical method of performing the "linearization about zero" discussed in Section 2.2 as applied to the corrective moment curve.
The corrective moment coefficient $C_1$ is just the slope of this straight line
// === page 176 ===
#figure(
  image("/assets/figures-original/fig2-45.png"),
  caption: [Computing angle of attack in radians and corrective moment in dyne-centimeters.
The angle of attack in degrees is divided by 57.3 to convert to radians; the mass on the balance pan, in grams, is multiplied by 980 times the radius of the pulley wheel in centimeters to give the moment in dyn-cm.]
) <fig:2-45>
// === page 177 ===
and may be computed by locating any point on the straight line and dividing its moment coordinate by its deflection coordinate.
The result is $C_1$ given in dyne-centimeters per radian, but this should be expressed as simply dyne-centimeters because radians (as stated in Section 4.7) are physically dimensionless.
@fig:2-46 illustrates the graphical reduction of data for a hypothetical rocket.

You may wish to repeat the experiment at a number of different values of airspeed to determine the dependence of $C_1$ upon velocity.
If you do this, you will find that $C_1$ is directly proportional to the square of the airspeed.

=== The Damping Moment Coefficient <sec:2-5.3>

The dynamic parameter $C_2$ is determined using the same gimbal arrangement as in the first experiment, with the exception that the pulley wheel and its associated pan and counterweight system must be removed.
This must be done in order to reduce the moment of inertia contributed by the rotating parts of the balance system, and unless this modification is carried out the rocket will behave as if its longitudinal moment of inertia were much greater than it actually is.

The experiment is prepared by balancing the test rocket so that the shaft passes through its center of mass as before, setting the airspeed to the desired value --- which must remain constant throughout the test --- and checking to make certain that the angle indicator is reading zero.
Having completed these preliminary steps, deflect the rocket to some moderate angle of attack, say $10 degree$, and hold it steady in this position.
You may wish to have an assistant do this by turning the shaft
// === page 178 ===
#figure(
  image("/assets/figures-original/fig2-46.png"),
  caption: [Graphical reduction of wind tunnel test data to determine the corrective moment coefficient.
(a): A table of corrective moment vs. deflection angle is compiled.
(b): The data points on the table are transferred to a graph and a smooth curve is drawn (as nearly as possible) through the points.
(c): A straightedge is placed along the lower portion of the curve, tangent to it at the origin, and a line is drawn using the straightedge as a guide.
The slope of this line is the corrective moment coefficient.]
) <fig:2-46>

// === page 179 ===
with his hand in order to allow you to best observe the subsequent motion, or you may devise various automatic systems to do the job.
One simple technique for obtaining the initial deflection would be to wrap a length of strong thread around the end of the shaft from which the pulley has been removed and tie a weight to the thread.
In any case, record the value of the initial deflection thus produced, identifying it as $alpha_0$.

Now release the rocket and allow it to rotate into the wind of its own accord.
If you have used the thread-and-weight system for producing the initial deflection, you can do this by carefully snipping the thread with a pair of scissors.
The rocket should swing toward alignment with the wind axis and _overshoot_ it, reaching a maximum angle which I shall refer to as $alpha_1$ on the opposite side of zero from that on which the model was released, and subsequently oscillating with smaller and smaller amplitude about zero until it is facing steadily into the oncoming wind.
The convention for representing $alpha_0$ and $alpha_1$, whose algebraic signs are both taken as positive, is shown in @fig:2-47.
The maximum overshoot angle $alpha_1$ will be reached at a time defined as $t_"max"$ after the rocket is released.
You must accurately record both the maximum overshoot angle and the time at which it occurs.
In the case of indicating systems consisting only of a simple pointer-and-protractor $alpha_1$ must be recorded by eye (or by photographic means) and $t_"max"$ by a stopwatch.
An electrical system for measuring and recording the deflections has a significant advantage here, in that it takes the guesswork out of the observations.

If, upon being released, the model does not oscillate at
// === page 180 ===
#figure(
  image("/assets/figures-original/fig2-47.png"),
  caption: [Convention for defining $alpha_0$ and $alpha_1$ in the experiment for determining the damping moment coefficient.]
) <fig:2-47>
// === page 181 ===
all but instead slowly faces into the relative wind from the position of initial deflection, it is overdamped.
As shown by the results of Section 3.1.1, this is a hazardous condition which may result in an erratic flight path and the rocket must be redesigned to correct it.
Additional nose weight will usually take care of this problem, but since this moves the center of mass forward it will require the building of a new test model which is divided in two further toward the nose.
Alternatively, both the nose and the tail of the model can be weighted, keeping the C.G. in the same place but increasing the longitudinal moment of inertia.

Assuming that the rocket has behaved in a properly oscillatory fashion and that $alpha_0$, $alpha_1$, and $t_"max"$ have all been duly recorded, the value of the damping moment coefficient may now be computed.
The first step is to determine the inverse time constant $D$ according to the relation

#eqn("113")[$ D = ln(alpha_0 / alpha_1) / t_"max" $] <eq:2-113>

where the reader is reminded that the notation “$ln(alpha_0 / alpha_1)$” refers to the natural logarithm of $(alpha_0 / alpha_1)$.
Readers who are mathematically adept may recognize that equation (113) is derived from the peaking characteristics of decoupled, underdamped step-response presented in equations (32), Section 3.1.2.

With $D$ known from Eq. #eqref(<eq:2-113>) and $I_L$ known from torsion-wire determinations, it is possible to calculate $C_2$ from equation (16), Section 3.1.1, as

#eqn("114")[$ C_2 = 2 I_L D $] <eq:2-114>
// === page 182 ===
As when determining the corrective moment coefficient, you may wish to perform this test at various airspeeds.
In doing this you will find that $C_2$ increases linearly with airspeed so that the values of the decoupled and coupled damping ratios, as predicted by the Barrowman equations, remain constant.
Eq. #eqref(<eq:2-114>) determines $C_2$ in units of dyne-centimeter-seconds.

== Model Rocket Design <sec:2-6>

I have often remarked during the foregoing presentations that the true purpose and real value of all the mathematical analyses to which we have turned our attention in this volume lies in the fact that they enable the formulation of rational rules for the _design_ of model rockets.
We have now progressed sufficiently far in our analytical considerations of the dynamic behavior of model rockets that we are prepared to discuss the subject of model rocket design insofar as it is influenced by dynamical considerations.
To “design” a rocket, from the standpoint of dynamics, is to adjust its shape and mass distribution so as to produce values of the dynamic parameters which give rise to favorable characteristics in its dynamic response.
“Favorable characteristics,” in turn, mean that:

(a) The rocket is not easily disturbed, or deflected from its intended direction of flight.
For a given disturbing influence, the angle through which it rotates is small.

(b) The rocket soon returns to a straight and true flight path once the disturbance has passed, and does so in an oscillatory fashion so that the effect of the disturbance is evenly distributed about the intended flight axis.
// === page 183 ===
=== Representative Parameters <sec:2-6.1>

The solutions to the dynamical equations given in Section 3 predict that favorable dynamic behavior in various particular situations will be associated with certain ranges of values of the dynamic parameters or combinations thereof.
As it happens, however, the dynamic parameters of a model rocket cannot be varied independently of one another.
Even if they could, it turns out that relations between the parameters best for one response are not necessarily best (or even acceptable) with respect to other types of disturbances.
The designer of model rockets thus finds himself faced with the necessity to make certain compromises --- “tradeoffs”, they are called by professional engineers --- in order to arrive at a configuration which, on the whole, has favorable performance.
The situation is further complicated by the fact that characteristics which are best for dynamics may not always be best for other aspects of rocket performance --- altitude capability, for example.
In order to guide himself to a rationale by which design compromises can be made the rocketeer needs two classes of information: first, what values of the parameters characterize a typical, or representative model; and second, what is the effect of varying the configuration of the model upon the values of its parameters?

In order to supply an answer to the first question the typical model rocket configuration DTV-1, illustrated in @fig:2-48, was constructed and tested according to the methods of @sec:2-6 in the low-turbulence wind tunnel of the Massachusetts Institute of Technology’s Aeronautical Projects Laboratory.
// === page 184 ===
#figure(
  image("/assets/figures-original/fig2-48.png"),
  caption: [Dynamic test rocket DTV-1. All dimensions are given in centimeters, with the exception of the engine casing specifications. These are given in millimeters in accordance with international convention.]
) <fig:2-48>
// === page 185 ===
Plate 1: DTV-1 undergoing wind tunnel test to determine its damping moment coefficient.
The model is mounted on a moment balance similar to the one pictured in Figure 44, but without the pulley wheel assembly and equipped with a photoelectric angle indicating device.
In frame (a) the model has just been released from the angle $alpha_0$.
In (b) and (c) it is accelerating in pitch up.
(d): The model passes through zero angle of attack at its maximum pitch rate, still pitching up but slowing in (e) and (f).
(g): The rocket is at its maximum pitch-up deflection, $alpha_1$.
(h), (i): The model begins to pitch downward again.
(j), (k), (l): The rocket passes through zero again on its way down to complete its first full cycle of oscillation.
// === page 186 ===
#image("/assets/figures-original/plate2-1a.png")
// === page 187 ===
#image("/assets/figures-original/plate2-1b.png")
// === page 188 ===
DTV-1 was found to have the following dynamic parameters:

$! C_1 = 0.65 V^2 quad "dyne-centimeters, where " V " is given in" \ "centimeters per second" $

$! C_2 = 10.5 V quad "dyne-centimeter-seconds" $

$! I_L = 9100 quad "gram-centimeters"""^2 $

$! I_R = 178 quad "gram-centimeters"""^2 $

The rocket’s roll rate during a number of additional experiments in which its behavior under roll-coupled resonance was investigated was an independent variable determined by the speed of an electric motor mounted on a balance system that was essentially a more refined form of that discussed in Section 5.3.
It will be seen from the above figures that the following quantities are also characteristic of the rocket:

$! omega_n = .00845 V $

$! zeta = .0682 $

$! (I_R omega_z) / I_L = .0195 omega_z $

$! omega_(n c) = .00838 V $

$! zeta_c = .0675 $

where $V$, the airspeed, is given in centimeters per second and $omega_z$ in radians per second.
Now it is probable that DTV-1 is not precisely in the center of the average range of model characteristics; it is rather on the heavy side and has a static stability margin of three calibers.
Nevertheless, it is certainly representative enough to allow the following general statements to be made:

(1) In a model rocket of average design, the damping ratio tends to be low --- on the order of one tenth.
Resonance, when
// === page 189 ===
it occurs, tends to be a problem and will usually be caused by the development of a roll rate whose value is close to the natural frequency.
Overdamping, on the other hand, is much less common and not usually to be feared.

(2) The radial moment of inertia is very slight compared to the longitudinal moment of inertia --- on the order of a few percent.
The roll rate must be very rapid to produce appreciable gyroscopic moments.
Therefore, the angular frequencies and rate of decay of the response of an average model rocket subjected to transient disturbances while spinning about its longitudinal axis are very nearly equal to those that would describe the behavior of the same rocket if it were not spinning at all, unless the spin is very rapid.
By “very rapid” I mean that the gyroscopic precessional frequency $(I_R omega_z) / I_L$ is, say, 10% or more of the natural frequency.
For DTV-1 during powered flight this would mean a spin rate on the order of 100 radians (about 16 revolutions) per second.

(3) As another consequence of the small radial moment of inertia, the resonance condition for a given rocket is nearly the same when it is rolling as when it is not; i.e., the natural frequency is nearly equal to the _coupled_ natural frequency and the damping ratio is nearly equal to the _coupled_ damping ratio.
This is an advantage in that the presence of roll does not appreciably increase the severity of the resonance.

=== Effects of Varying the Parameters <sec:2-6.2>

Having roughly bracketed the “average” or “representative” dynamic parameters, we can start to investigate what happens when a rocket departs from the average range in various ways.
// === page 190 ===
We must remember, when doing this, to take into account factors affecting other aspects of the rocket’s performance (such as its overall weight and drag) as well as those affecting its rigid-body dynamics.

First, consider the effect of increasing the longitudinal moment of inertia of the rocket.
This can be done by adding weight at points far fore and aft of the center of gravity, usually making the rocket longer as well as heavier.
The damping ratio and natural frequency of oscillation will decrease, and the rocket will be more difficult to deflect from its intended path.
If this is carried to extremes, however, the rocket will become so heavy that its altitude capabilities will be sharply reduced and it will experience catastrophic resonance at very low roll rates, resonance so severe that the model may behave as if it had insufficient static stability.
The dramatic manner in which resonant amplitude ratio increases with decreasing damping ratio is shown in @fig:2-49.
There is evidence that some model rockets have actually been caused to crash by excessive resonance at low roll rates early in the flight.
Rocket A of @fig:2-50 is an example of how a model designed with too great a longitudinal moment of inertia might look.

_Decreasing_ the longitudinal moment of inertia will increase both the damping ratio and the _natural frequency_; the _actual_ angular frequency of oscillation will increase only up to a point, then begin to decrease towards zero as the damping ratio approaches 1.0.
The resonance problem will disappear, but the rocket will be more easily deflected from alignment with the intended flight path.
The slightest disturbance will be enough to start it
// === page 191 ===
#figure(
  image("/assets/figures-original/fig2-49.png"),
  caption: [Variation of resonant amplitude ratio with damping ratio. A curve of precisely the same form describes the variation of _coupled_ resonant amplitude ratio with _coupled_ damping ratio.]
) <fig:2-49>
// === page 192 ===
#figure(
  image("/assets/figures-original/fig2-50.png"),
  caption: [Improperly designed model rockets resulting from extreme variations in the relative values of the dynamic parameters.]
) <fig:2-50>

// === page 193 ===
wobbling, and although the oscillations will die away after only a few cycles the rocket will be disturbed so often that it will spend much of its upward flight at a considerable angle of attack.
Its drag will thus be increased and its altitude lowered --- particularly since a low longitudinal moment of inertia usually means a low weight and the rocket may already be _ballistically_ off-optimum#footnote[There is an optimum weight for any rocket, which gives the greatest altitude.
See George Caporaso's chapter on trajectory analysis in this volume for an explanation.].
Continued reduction of $I_L$ causes overdamping, and the model behaves as if it had an insufficient static stability margin.
An example of this extreme is rocket B of Figure 50.
Between 1962 and 1967 there was a marked trend toward this kind of design in the United States.
Modelers at that time believed that the lighter a rocket was, the higher it would go, and so constructed all their altitude competition designs to be very light and stubby, with huge fins.
The result was often excessive damping, sometimes even overdamping, causing severe launcher tipoff, erratic flight paths, and many a pile of wreckage.
Thanks to Malewicki and Caporaso --- who developed the equations of model rocket ballistics --- and to Barrowman --- who demonstrated analytically the fin areas actually needed by model rockets --- and to much sad experience and observation, this fetish is largely a thing of the past.

Suppose we now consider the effect of increasing the corrective moment coefficient.
If this is done by increasing the static stability margin --- by increasing the area of the fins and/or moving them further toward the rear of the rocket --- the frequency at which the rocket oscillates when disturbed
// === page 194 ===
will increase.
Since altering the fin geometry in this way also increases the damping moment coefficient, the damping _ratio_ will not necessarily decrease; it may even _increase_ if the practice is carried to extremes.
Thus, the _time_ required for the disturbed rocket to return to proper alignment with the intended flight direction becomes shorter --- and, because the longitudinal moment of inertia has not been appreciably changed, the rocket is no easier to disturb than it was before.
On the face of it, the modification appears to be a favorable one.

Unfortunately, though, there are also disturbances whose magnitude is directly proportional to the static stability margin and normal force coefficient of the model, notably the step disturbances due to horizontal winds.
If the value of the static stability margin is made too great the rocket will therefore be subject to excessive "weathercocking", or turning into the wind during flight.
This impairs altitude performance, makes recovery difficult, and can be dangerous.
Most designers soon learn to steer clear of configurations like that of illustration C in Figure 50.

There is, of course, a better way to obtain a large corrective moment coefficient.
The value of $C_1$, you will recall, increases as the square of the airspeed.
This does _not_ necessarily indicate that the "way to go" in model rocket design is to try for the highest possible velocities throughout the flight.
While high burnout velocity generally means higher altitude, excessive accelerations achieved at the expense of burnout altitude cause excessive aerodynamic drag which can actually cause the
// === page 195 ===
altitude achieved to be reduced.
What it _does mean_ is that you should observe a reasonable minimum in the velocity at which your rocket leaves its launcher.
Model rocket engines with end-burning grains are designed with a small port at the after end of the grain, just inside the nozzle.
The purpose of this, besides providing a place to pack the igniter, is to provide a high initial thrust to achieve a substantial airspeed --- and thus a substantial corrective moment --- before the guiding influence of the launcher is left behind.
You can best take advantage of this initial thrust peak by providing a long enough launching device and avoiding excessive liftoff weight, thereby insuring that your rocket leaves its launcher at a sufficient velocity to be stable.
#qty(9, "m/s") should be considered a minimum safe launch speed, and #qty(12, "m/s"), if possible, would be advisable.
If you are using a core-burning engine, of course, velocities on this order should never be a problem.

_Reducing_ the corrective moment coefficient by reducing the static stability margin will cause the natural frequency to decrease.
As the center of pressure moves forward and approaches the center of gravity, the damping ratio will increase, lowering the actual frequency of oscillation until overdamping occurs.
Moving the center of pressure still further forward will result in neutral, and finally negative, static stability.
Only the novice designer is ever caught making an error of this kind, and when he does the result is spectacular.
"Going ape" is the colorful and appropriate phrase applied by the model rocketeer to the behavior of a statically-unstable
// === page 196 ===
rocket such as the one appearing in illustration D of Figure 50.

The damping moment coefficient may be increased by the addition of fin area or the movement of fins to a position farther from the rocket's C.G., in the same way that the static stability margin is increased.
Adding large amounts of fin area both forward and aft of the center of gravity, however, and the use of excessive fin area in general, will tend to increase the damping moment coefficient without a commensurate increase in corrective moment coefficient.
Dynamically, up to a point (the point at which the damping ratio becomes .7071) this is good.
Ballistically, however, such large surfaces are almost always associated with a decrease in altitude because of excessive drag.
Working at such high damping ratios is not a good idea in general anyway, because a slight change of design or modification to a rocket in service or under construction could well send it "over the line" into an overdamped configuration.
Rocket E of Figure 50 is an example of what the designer may wind up with if he is too liberal with his sheet balsa.

The damping moment coefficient, insofar as it is dependent on fin geometry, may be _reduced_ by making certain that all fin area is aft of the center of gravity but not greatly distant from it.
Since placing the fins relatively near the center of gravity tends to reduce the corrective moment coefficient also, this procedure may not always reduce the damping _ratio_ and may even increase it.
Reducing the damping ratio to very small values is not a good idea in any case, since under these conditions the oscillations of a deflected rocket persist for a long time
// === page 197 ===
and resonance becomes destructively severe.
Making the damping moment coefficient too small thus has the same effect as making the longitudinal moment of inertia too large.
The rocket of illustration F in Figure 50 has had its damping ratio made too small by placing the fins insufficiently far from the center of gravity.
While the designer has apparently been able to keep the static stability margin adequate, his rocket will not be a good performer.
Much of its trajectory will be spent oscillating in response to various disturbances even if it does not happen to develop a resonant roll rate --- in which case its useful operating life will be short indeed.

The limitations of reasonable design and the standardization of component proportions arising from mass-produced model rocket supplies do not really leave much leeway for regulating the radial moment of inertia independently of the longitudinal moment of inertia.
Assuming that $I_R$ could be substantially reduced, the effect of such a reduction would be negligible since $I_R$ is so small to begin with.
The radial moment of inertia could conceivably be greatly increased by placing weighted pods, or "bobs" at the tips of the fins, but there would be no point in doing so.
No advantage would be gained if the rocket were properly designed to begin with; in fact there would be some unfavorable consequences attendant upon such a modification.
The rate of decay of the rocket's oscillations would be suppressed by gyroscopic moments if it were rolling, and its roll-induced resonance would be much more severe than its non-rolling resonant behavior.

=== Rolling Rockets <sec:2-6.3>
// === page 198 ===
My last statements above were, of course, promulgated on the assumption of a statically-stable rocket.
In cases of insufficient, neutral, or negative static stability it is necessary to induce a rapid spinning of the rocket about its centerline in order to generate the stability-like effect described in Section 3.2.5.
The extent to which stability is effected by this artifice is dependent, it will be recalled, on the magnitude of the _product_ of $I_R$ and $omega_z$.
It is thus desirable to have a rapid spin, a high radial moment of inertia, or both.
Successful spin-stabilized rockets and projectiles tend to be short, squat, and heavy.
It is this fundamental difference in the physical mechanism by which stable behavior is produced that accounts for the configurational differences between aerodynamic vehicles such as sounding rockets and objects such as artillery shells.
Well-designed sounding rockets are long in relation to their diameters, while artillery shells are short.
Why the difference?
The reason, of course, is that the sounding rocket is aerodynamically stable while the artillery shell is not.
It is an advantage to the shell to have a large diameter in relation to its length because this means a large radial moment of inertia, facilitating spin stabilization.
The sounding rocket, on the other hand, performs best at a higher slenderness ratio since it relies on the corrective and damping characteristics due to its fins and on its high longitudinal moment of inertia for favorable dynamic response, not to mention the great advantage in altitude capability that goes with a more slender profile.

Stabilization is not, however, the only motive for inducing
// === page 199 ===
spin in model rockets.
It has been found that rolling models are less subject to "dispersion" by horizontal winds and tipoff during launch and staging than those which are not, where by "dispersion" I mean the horizontal displacement of the rocket at the time of recovery system actuation.
The roll rates used in dispersion-reduction are much lower than those used in roll stabilization, since the rockets to which they are applied are already statically stable; the inertial effect is generally slight and its only purpose is to induce just enough roll coupling to distribute the effects of disturbances in a radially symmetrical fashion about the intended axis of flight.

A roll rate may be induced in a model rocket in a variety of ways.
The major aerodynamic techniques in current use include "spinnerons" (that is, fin tabs), canted fins, and airfoiled fins as illustrated in @fig:2-51.
Canted main propulsion or outrigger engines have also been used to "spin up" model rockets, and from time to time flywheel-like devices have appeared whereby a product $I_R omega_z$ _other_ than that of the rocket airframe itself has been used to provide inertial coupling.
The number and variety of roll-inducing techniques possible is so great, indeed, that it is impossible to write down any single analytical expression accounting for them all.
In the particular case of spin produced by canting each fin of a rocket at some angle $theta$ to the longitudinal axis, however, Barrowman analysis permits computation of the equilibrium roll rate in the form

#eqn("115")[$ omega_z = (12 theta V AR overline(Y)_T k_r)/(s c_r k_d [(1 + 3 lambda) s^2 + 4(1 + 2 lambda) s r_t + 6(1 + lambda) r_t^2]) $] <eq:2-115>
// === page 200 ===
#figure(
  image("/assets/figures-original/fig2-51.png"),
  caption: [Aerodynamic techniques used for inducing roll in model rockets.]
) <fig:2-51>
// === page 201 ===
where $k_r$, the roll forcing interference coefficient, is given by

#eqn("116")[$
k_r = 1/pi^2 [
  pi^2/4 ((tau + 1)/tau)^2
  + pi/12 ((tau + 1)/(tau - 1))^2 arcsin((tau^2 - 1)/(tau^2 + 1))
  - (2 pi)/tau ((tau + 1)/(tau - 1))
  + 8/(tau - 1)^2 ln((tau^2 + 1)/(2 tau))
  + ((tau^2 + 1)/(tau (tau - 1)))^2 (arcsin((tau^2 - 1)/(tau^2 + 1)))^2
  - (4(tau + 1))/(tau(tau - 1)) arcsin((tau^2 - 1)/(tau^2 + 1))
]
$] <eq:2-116>

and $k_d$, the roll damping interference coefficient, is

#eqn("117")[$
k_d = 1 + ((tau - lambda)/tau - (1 - lambda) ln tau)/(((tau + 1)(tau - lambda))/2 - ((1 - lambda)(tau^3 - 1))/(3(tau - 1)))
$] <eq:2-117>

$overline(Y)_T$ is given by equation (90), $lambda$ is the ratio $c_t/c_r$, and $tau$ is the ratio $(s + r_t)/r_t$.
The reader should refer back to Section 4.1 for additional information concerning the notation used in equations (115) through (117).

Given the ability to regulate the roll rate of his rocket, the designer will next want to know what roll rates are favorable to good performance.
This question is generally answered by eliminating those ranges of roll rate which are deleterious to good performance and stating that the ranges then remaining are acceptable.
The roll rate that should be avoided at all costs is, of course, the roll-coupled resonant rate.
In models where roll is produced by fin canting this is relatively easy to do, as both the resonant frequency and the roll rate are linear functions of airspeed.
$omega_z$ can thus be kept as nearly zero as possible (the most common course of action), uniformly much lower than $omega_(n c)$ (the technique adopted when dispersion-reduction is desired), or uniformly much higher than $omega_(n c)$.
This last technique is not recommended, as it results in large coupling moments, a high-drag configuration, and (often) tangling of the shrouds of parachute recovery systems.
The selection of
// === page 202 ===
available relations between $omega_z$ and $omega_(n c)$ in rockets whose roll rate is set by fin canting is illustrated in Figure 52.
Perhaps you can now see the danger of resonance associated with too high a value of $I_L$; a very high longitudinal moment of inertia means a very low resonant frequency, and it is entirely possible that small fin cant angles arising from imperfections in construction will be just sufficient to produce the low spin rate needed for resonance.

In cases where it is desired to stabilize a statically-unstable design by inducing roll, there is of course no resonance problem.
The fin cant angles and spin rates required for roll stabilization are very high, though, and this means very poor altitude performance and a high probability of tangling the recovery system shrouds at ejection.
The relative ease with which positive aerodynamic stability can be achieved by proper design procedures and the relatively poor performance of unstable rockets which require high roll rates for spin stabilization make it really inexcusable to use roll stabilization as the primary means of achieving a predictable flight path.
Spin stabilized rockets are to be regarded as curiosities, in the final analysis suitable only for demonstration purposes.

=== Design Procedures and Criteria <sec:2-6.4>

With the results of all our investigations now lying ready to hand, it is possible to formulate a rational procedure permitting the modeler to design, with a high degree of confidence, a model that will behave both ballistically and dynamically in a favorable manner.
Such a method, suitable for all general-purpose design and competition work, may be summarized as follows:
// === page 203 ===
==== Design Definition: Center of Gravity and moments of Inertia <sec:2-6.4.1>

Define, as nearly as possible, the purpose of the proposed model.
Is it to be, for instance, used in altitude or payload competition, for photographic or sounding work, or some other "mission"?
Need it be staged?
Should it be clustered?
What must be the payload capacity, if any?
What recovery system is to be used?
The answers to questions such as these will roughly define the size and shape of the rocket's body and nose sections.
A preliminary drawing can then be made showing the body and nose and all the components contained within them or of which they are comprised (engines, payload, bulkheads, etc.).
A preliminary estimate of the C.G. location and moments of inertia of the design thus far evolved should then be computed.

==== Static Stability Margin <sec:2-6.4.2>

Add a fin design to the drawing and compute the various normal force coefficients and C.P. locations of the components and of the complete rocket by the Barrowman method.
If the rocket is multistaged it will be necessary to perform the calculations for each configuration of stages in which the model is intended to fly.
The C.P. should lie between one and two calibers behind the C.G.; if it is outside this range, try a new design.
In contest or record work, where reduction of weathercocking is of paramount importance, many designers prefer to try for precisely one-caliber stability.

==== Damping Ratio <sec:2-6.4.3>

Using the information obtained thus far, compute the corrective moment coefficient and the damping moment coefficient
// === page 204 ===
according to the methods outlined in Section 4.
From these and the moments of inertia compute the damping ratio and the coupled damping ratio.
Check to insure that the coupled damping ratio is not less than 0.05 and that the decoupled damping ratio is not greater than 0.30.
A too-low damping ratio can be cured by lightening the rocket and increasing its fin area; an excessively high one by adding weight to the nose and decreasing the fin area.
While damping ratios up to 1.0 would be theoretically permissible, I have established an upper limit of 0.30 because it is my considered opinion that more heavily damped rockets are likely to be too light for good ballistic performance.
The resonant deflection of the rocket's centerline from its intended flight path at a damping ratio of 0.3 is only 1.746 times the deflection a static disturbance would produce (see Figure 49).
It should thus not really be necessary to use damping ratios higher than this value.
In accepting a lower limit of 0.05, on the other hand, you will really be pushing the builder's art; the roll-coupled resonant deflection will be _ten times_ the static deflection due to a given disturbance.
Assuming that a carefully-built model will incorporate unintentional asymmetries causing static deflections of no more than one-half of one degree, a damping ratio of 0.05 will permit such a model experiencing roll-coupled resonance to precess about its flight direction with a cone half-angle of five degrees.
Clearly, this is about the most we can accept.

==== Roll Rate <sec:2-6.4.4>

Determine whether it is desirable to induce a roll rate in your vehicle for the reduction of dispersion and tipoff.
// === page 205 ===
Such a determination will be almost entirely a matter of your opinion as a designer, since the tradeoff between control of roll rate and control of static stability margin as a means of reducing dispersion is extremely subtle.
The decisions of most designers seem to run in favor of roll rate control only in the case of multistaged models.
If you decide to induce a roll rate by means of canted fins, compute the fin angle required for the linear velocity-dependence you desire, being careful to keep away from the resonant frequency.
The analytical prediction of roll rates due to other means must await further advances in the state of our technology.

==== Construction and Testing <sec:2-6.4.5>

When the above steps are completed and the dynamic parameters of the proposed design have been found to be satisfactory, construction can be started.
It would be desirable to measure the C.G. location and moments of inertia at several stages during the construction, and to measure the dynamic parameters of the completed model before the first flight to check the accuracy of the estimates and calculations.
Barring any major errors in these, the design determined by the above method will be sound.

In practice, of course, a wide variation in design procedures will be found to be acceptable.
The designer of a sport model need only be concerned with the static stability margin, while competition and research modelers will want to make full use of all the available analytical techniques in adjusting their designs for the greatest possible fulfillment of the missions for which they are designed.
As our technology advances it may
// === page 206 ===
be expected that many designers will have recourse to parametric data generated by automatic computation as they apply ever more detailed design procedures to the challenging problems of model rocket optimization.

#bibliography("../refs-ch2.yml", style: "ieee", title: "References", full: true, group: none)