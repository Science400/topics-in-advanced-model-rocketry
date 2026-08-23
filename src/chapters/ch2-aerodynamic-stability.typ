#import "../preamble.typ": conflict, minor, unit, qty, qtyrange, num, eq, eqref, symbol-table, chapter-setup, AR
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
      [$overline(Y)_T$], [radial position of C>P> of a single fin],
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

#heading(numbering: none, level: 2)[Introduction] <sec:2-0>

== The Dynamical Equations <sec:2-1>

=== Euler's Angles <sec:2-1.1>

=== Angular Velocity <sec:2->

=== Applied Moments, Angular Accelerations, and Moment of Inertia <sec:2-1.3>

=== Euler's Dynamical Equations <sec:2-1.4>

== The Linearized Theory <sec:2-2>

=== Corrective and Damping Moment <sec:2-2.1>

=== The Linearization Approximations <sec:2-2.2>

=== Coupled and Decoupled Systems of Equations <sec:2-2.3>

=== Homogeneous, Particular, and Steady-State Solutions <sec:2-2.4>

== Solutions to the Dynamical Equations for Particular Cases of Interest <sec:2-3>

=== Dynamical Behavior at Zero Roll Rate <sec:2-3.1>

==== Generalized Homogeneous Response <sec:2-3.1.1>

==== Complete Response to Step Input <sec:2-3.1.2>

==== Complete Response to Impulse Input <sec:2-3.1.3>

==== Steady State Response to Sinusoidal Forcing <sec:2-3.1.4>

=== Dynamical Behavior at a Constant, Nonzero Roll Rate <sec:2-3.2>

==== Generalized Homogeneous Response <sec:2-3.2.1>

==== Complete Response to Step Input <<sec:2-3.2.2>

==== Complete Response to Impluse Input <sec:2-3.2.3>

==== Steady State Response to Sinusoidal Forcing at the Roll Rate <sec:2-3.2.4>

==== Roll Stabilization <sec:2-3.2.5>

== Analytical Determination of the Dynamic Parameters <sec:2-4>

=== Normal Force Coefficients and Center of Pressure: The Barrowman Method <sec:2-4.1>

=== Locating the Center of Gravity <sec:2-4.2>

=== The Corrective Moment Coefficient <sec:2-4.3>

=== The Damping Moment Coefficient <sec:2-4.4>

=== The Longitudinal Moment of Inertia <sec:2-4.5>

=== The Radial Moment of Inertia <sec:2-4.6>

=== General Properties of the Parameters <sec:2-4.7>

== Experimental Determination of the Dynamic Parameters <sec:2-5>

=== Moments of Inertia: The Torsion-Wire Experiment <sec:2-5.1>

=== The Corrective Moment Coefficient <sec:2-5.2>

=== The Damping Moment Coefficient <sec:2-5.3>

== Model Rocket Design <sec:2-6>

=== Representative Parameters <sec:2-6.1>

=== Effects of Varying the Parameters <sec:2-6.2>

=== Rolling Rockets <sec:2-6.3>

=== Design Procedures and Criteria <sec:2-6.4>

==== Design Definition: Center of Gravity and moments of Inertia <sec:2-6.4.1>

==== Static Stability Margin <sec:2-6.4.2>

==== Damping Ratio <sec:2-6.4.3>

==== Roll Rate <sec:2-6.4.4>

==== Construction and Testing <sec:2-6.4.5>

#bibliography("../refs-ch2.yml", style: "ieee", title: "References", full: true, group: none)