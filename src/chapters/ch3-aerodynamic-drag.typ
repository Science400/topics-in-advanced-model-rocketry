#import "@preview/mitex:0.2.7": mitex, mi
#import "../preamble.typ": conflict, minor, qty
#import "@preview/zero:0.6.1": num,
#import "@preview/unify:0.7.1": unit, numrange, qtyrange

// === page 11 ===
= The Aerodynamic Drag of Model Rockets <sec:ch3>

#heading(numbering: none, level: 2)[Introduction] <sec:introduction>

Like stability, aerodynamic drag has been a topic of intense interest in the field of model rocketry since the hobby was in its infancy in the late 1950's.
One does not have to look very far to find the reason for such interest: model rockets, owing to their lightweight construction and the fact that their operation is restricted to flight entirely within the lower reaches of the atmosphere, are more strongly affected by atmospheric resistance than any other type of ballistic, rocket-propelled vehicle.
The influence of drag upon the altitude performance of a model rocket is not a slight correction, but a major controlling factor, and no modeler who is seriously interested in accurate predictions of altitude capability can afford to ignore it or dismiss its effect lightly.

The early recognition of this fact by members of the National Association of Rocketry during the first year of that organization's existence led in 1958 to the first wind-tunnel test of a model rocket to determine its coefficient of drag.
The results of this test sequence, performed on a model of the Aerobee-Hi sounding rocket in the subsonic wind tunnel of the United States Air Force Academy, were published that same year by G.
Harry Stine in the first NAR Technical Report, "Basic Model Rocket Flight Calculations".
The same document contained
// === page 12 ===
the observation that aerodynamic drag is responsible for lowering the maximum altitude of a typical model rocket by more than 50%, and an expanded discussion of the same material contained in Stine's _Handbook of Model Rocketry_ (First Edition, 1965) reported altitude reductions due to drag of more than 90% in cases of exceptionally poor design.

The Aerobee-Hi tests remained nearly the sole source of experimental model rocket drag data for the next eight years.
From time to time various modelers would construct home-built wind tunnels and balance systems in an effort to obtain more data; most of these test facilities, however, were too crude to provide a low enough air turbulence level for accurate measurements.
Whatever valid data _were_ obtained, moreover, appeared to receive only local attention, and virtually no modelers attempted to adapt theoretical or semiempirical analytical treatments of the drag problem to cases of model rocket flight.
During the winter of 1965-1966, however, the NARHAMS Section of the National Association of Rocketry constructed a single-return-flow, low-speed wind tunnel with sufficiently low air turbulence to permit relatively accurate measurements of model rocket drag coefficients.
Mark Mercer of that section subsequently conducted an extensive parametric investigation of various modified forms of the Javelin, a commercially-available kit produced by the Centuri Engineering Company of Phoenix, Arizona.
The results of his tests, incorporated by Douglas J. Malewicki into Centuri's Technical Information Report TIR-100, _Model Rocket Altitude Performance_, represent the most complete
// === page 13 ===
set of experimental data on model rocket drag available to date.

During the same period, serious analytical and semiempirical studies of the model rocket drag problem first began to appear.
The Research and Development competition event at the Eighth Annual National Model Rocket Championships in 1966 saw the presentation of a paper by Dr. Gerald M.Gregorek of Ohio State University, entitled "A Critical Examination of Model Rocket Drag for Use with Maximum Altitude Performance Charts".
Dr. Gregorek's paper, a milestone in the hobby comparable to the advent of Barrowman analysis in stability determination, and to Malewicki's publication of altitude graphs based on closed-form solutions to the equations of vertical motion for model rockets, presented a semiempirical method for calculating the drag coefficient of a model rocket based on the _United States Air Force Stability and Control Datcom_ (Datcom being an acronym for #underline[Dat]a #underline[Com]pendium).
The Gregorek treatment deserves credit, not only for being the first in-depth, analytical discussion of the topic of model rocket drag, but also for motivating the growing body of literature on the subject that has appeared in the hobby since the original paper was presented and subsequently, widely circulated among interested local sections of the National Association of Rocketry.
Since its first appearance in 1968, the periodical _Model Rocketry_ has carried a number of articles concerned with the topic of drag coefficient determination by both experimental and analytical means.
Contributors to the literature over the past three years have included George J. Caporaso, Douglas J. Malewicki, Forrest M.
// === page 14 ===
Mims, Thomas T. Milkie, Gary Schwede, Dr. Gregorek himself, and several others.
It is in this atmosphere of increased interest in the determination of model rocket drag properties to a high degree of precision that the present chapter has been written.

The treatment to be presented here is divided into eight major sections, of which the first is a basic survey of the properties and importance of model rocket drag.
@sec:basic-concepts presents discussions of the basic concepts--drag coefficient, Reynolds number, and so on--which will be employed repeatedly in the subsequent sections.
Sections #ref(<sec:viscous-drag>, supplement: none) and #ref(<sec:pressure-drag>, supplement: none) contain analyses of the two major contributions to drag at a zero angle of attack: pressure forces and skin friction, while @sec:other-drag examines drag due to the side force (or "lift") on a yawed rocket, drag due to nonzero roll rate, and drag due to surface roughness.
@sec:zero-lift-drag-calc contains information of use in the practical calculation of drag coefficients for specific model rockets.
I have, for this purpose, used a slight modification of the _USAF Stability and Control Datcom_ method which is applicable to the regime of relatively low Reynolds numbers (usually under #num[3e6]) typically encountered in model rocketry.
In @sec:transonic-supersonic-drag a semiempirical method of accounting for the effects of compressible airflow on the drag coefficients of extremely high-performance model rockets is considered, and the chapter is concluded with a survey of experimental methods for the determination of model rocket drag.

The accurate determination of model rocket drag requires a rather precise knowledge of the airflow pattern which exists
// === page 15 ===
around the vehicle in question.
This, in turn, must be determined by applying the theories of _fluid dynamics_--that branch of mathematical physics which concerns itself with the study of liquids and gases in motion.
The general equations of fluid dynamics, named the Navier-Stokes equations in honor of those who first formulated them in the mid-Nineteenth Century, are among the most complex and difficult known to man.
A strongly _coupled set of nonlinear, partial differential equations with nonconstant coefficients_, they have never been solved in their full generality.
Even most of the highly-specialized approximations to these equations used in determining model rocket drag are therefore quite complicated and require the methods of calculus for their solution.
Mathematical derivations employing calculus have been used freely throughout the chapter for the benefit of those advanced readers who have an interest in them and who require some analytical justification for the conclusions eventually reached through their application.
Those who have no knowledge of (or interest in) advanced mathematics need not give up in despair, however, for the equations ultimately derived by all the calculus manipulation--the equations actually used in the calculation of model rocket drag coefficients--are all algebraic and capable of being solved by anyone who has had the first year of high school algebra.

A number of books and papers have been used as references in the compilation of this chapter.
Rather than refer to each one by name as material based on it is presented, I have cited references by footnote numbers.
The work identified by
// === page 16 ===
a given number may be found by consulting the reference list at the end of the chapter.

== Basic Considerations <sec:basic-considerations>
The study of drag forces on model rockets is one of the most difficult, exciting, and important problems facing the modeler today.
The amount of experimental work of significant value which has been accomplished in this field is relatively limited; many questions remain unanswered, and many of the physical phenomena involved are imperfectly understood.
My intention in writing this is not to close the question of model rocket drag, but to provide basic information and methods which, it is hoped, will be extended, refined, improved upon and added to by modelers engaged in future serious research.
The reader is encouraged to view all applications of theory to model rockets presented in the following pages with a critical eye, for until a really sizeable body of experimental data is available, many conclusions must remain tentative and subject to revision.

By definition, drag is _the sum of the components of all the aerodynamic forces acting on a body parallel to its instantaneous velocity vector with respect to the air_.
The algebraic sign of any component of drag is taken as positive when it acts in a direction _opposite_ to the direction of the model's motion.
Defined in this manner, the total drag of any body is, of course, positive.
The drag of a model rocket is a complicated function of its size, shape, finish, velocity, and angle of attack, and of the thermodynamic state of the air.
// === page 17 ===
Even for relatively simple rocket shapes, the relationship between drag and the variables upon which it depends is virtually impossible to predict with any precision on a purely theoretical basis.
Resort must be had to semiempirical methods--composites of theoretical predictions and experimental data--like the one employed in @sec:zero-lift-drag-calc; hence the need for extensive experimental research on model rocket shapes, to confirm (or if necessary, correct) any such method.
In @model-rocket-drag the definition of drag (which is considered to originate from the model's center of pressure, or C.P.), and the multiplicity of factors which determine its magnitude, have been illustrated.

Because of their lightweight, low-density construction, model rockets have lower ratios of weight to frontal and surface area than any other class of ballistic, rocket-propelled bodies.
Hence, aerodynamic drag has a greater influence on the flight of model rockets than it does on the flight of other rocket-propelled vehicles.
In a typical model rocket at burnout, the drag is of the same order of magnitude as the weight, and thus has a considerable effect on the coasting portion of the model's flight.
During the powered portion of flight, when the engine is providing a thrust that is normally eight or ten times the model's weight, the influence of drag is of course lessened; its effect on the overall flight performance, however, is always considerable, and it is a rare occurrence for a model rocket to reach more than half the altitude it could have achieved, were aerodynamic drag altogether absent.
In some high-performance models, moreover, the drag can become
// === page 19 ===
much greater than the weight, so that the drag and weight taken together are equal and opposite to the thrust of the engine.
This condition creates a _terminal velocity_ which the rocket cannot exceed, even if the burning time of the engine is relatively long.
The minimization of aerodynamic drag is, therefore, one of the prime considerations in the design of high-performance model rockets.

#figure(
  image("../../assets/figures-original/fig3-1.png"),
  caption: [Definition of drag and the variables that determine its magnitude.
  The size, shape, surface finish, and to some extent the airspeed and angle of attack of the rocket are under the designer's control.
  The atmospheric density and viscosity, and the speed of sound, are properties of the medium to which model rocket flight is confined.
  The sound speed influences drag through its relation to compressibility effects.]
) <model-rocket-drag>

Analytical knowledge of the physical phenomena which underlie drag is, like most scientific knowledge, of interest for its own sake.
More important to the model rocketeer, however (and the reason it is presented in this book), is that it has distinctly practical applications in the design of rockets.
It helps to explain, for instance, why rounded nosecones, streamlined fins, and smooth surface finishes--features which have been advocated for years--are in fact effective means of reducing the drag.
As another example, it is impossible to predict the drag of a rocket accurately without an understanding of the boundary-layer approximation, and of the transition phenomenon characteristic of boundary-layer flow in the Reynolds number regime in which model rockets operate.
And so it is that rather extensive use of mathematical derivation, though admittedly burdensome to the average hobbyist, is unavoidable in any thorough discussion of model rocket drag.
I reiterate, however, that one need not be a mathematician to make use of the information contained herein.
Remember that we are taking a basically engineering approach: we are interested in the _results_ of the mathematical derivations.
And in each case
// === page 20 ===
and each constituent of aerodynamic drag considered, it will be found that these results are no more difficult to work than, say, the equations of Barrowman analysis.

== Basic Concepts Relating to the Study of Drag <sec:basic-concepts>
This section will lay the foundation for a detailed analysis of drag forces by presenting a number of basic concepts and ideas.
@sec:atmospheric-properties will examine certain physical properties of the atmosphere, and the variation of these properties as they affect calculations of drag (and hence, altitude performance).
The dimensionless quantities defined and discussed in @sec:density will be used extensively in succeeding sections, particularly the Reynolds number $R$ and the drag coefficient $C_D$ .
@sec:drag-constituents concludes the treatment of basic concepts with a discussion of the scheme by which the total drag force is separated into components and analyzed in later sections.

=== Atmospheric Properties for Model Rocket Flight <sec:atmospheric-properties>
The physical properties of the atmosphere of greatest interest to model rocketry are its mass density $rho$, its absolute coefficient of viscosity $mu$, and the ratio between these two quantities, the kinematic viscosity $nu = (mu / rho)$.
Hence we shall restrict our attention to phenomena associated with these variables.
The atmospheric data presented herein is based on the *United States Standard Atmosphere, 1962* @us-standard-atmosphere, whose figures have been converted to MKS (meter-kilogram-second) metric units for model rocketry work.
This model of the atmosphere,
// === page 21 ===
based partly on experimental data, is an "idealized, middle latitude (approximately 45°) year-round mean over the range of solar activity between sunspot minima and maxima" @us-standard-atmosphere.
The assumed sea-level temperature for the tabulations is 59° Fahrenheit (15° Celsius or 288° Kelvin), with a standard sea-level pressure of 101,325 newtons per square meter (the MKS equivalent of the familiar 14.7 pounds per square inch).

==== Density <sec:density>
A measure of the drag force exerted on a rocket is the total momentum the rocket imparts to the originally stationary fluid through which it travels.
Momentum is directly proportional to the mass of the fluid displaced; and since the density of a fluid is simply its mass per unit volume, its connection with drag is established.
As mentioned in Chapter 1 and shown later in this chapter, the overall drag on a model rocket is directly proportional to the mass density of the air through which it flies.

Atmospheric density generally decreases with altitude, as seen in @fig:atm-density.
At an altitude of 300 meters, $rho$ departs from its sea-level value by just under 3%.
At 1000 meters, a respectable altitude for a model rocket, the deviation is just over 9%.
By the time a height of 3000 meters, the practical altitude limit for a model rocket, is reached the density has decreased by 25.6%.
Except in cases of extremely high performance models, the variation in atmospheric density during the course of a flight is rarely considered.
It is, however, fairly common for modelers to account for the elevation of their launch
// === page 22 ===
// Figure 2 <fig:atm-density>
// Figure 3 <fig:atm-temperature>
// === page 23 ===
sites by using the atmospheric density at the launcher elevation in their calculations of drag.

#figure(
  image("../../assets/figures-original/fig3-2.png"),
  caption: [Variation of standard atmospheric density with altitude above sea level.]
) <fig:atm-density>

#figure(
  image("../../assets/figures-original/fig3-3.png"),
  caption: [Variation of standard atmospheric temperature with altitude above sea level.]
) <fig:atm-temperature>

Density is also affected by the temperature of the air; in fact, the Standard Atmosphere density graph of @fig:atm-density is based on the relationship of temperature to altitude shown in @fig:atm-temperature.
It can be seen from the graph that the Standard Atmosphere assumes a so-called "linear lapse rate" of about #qty("1", "degC").
for each #qty("154", "m") of altitude.
As we all know from experience, however, the temperature at any given launch site may vary widely from day to day; for very precise performance calculations one might therefore wish to use the perfect gas law for correcting the density according to
#set math.equation(numbering: none)
$ rho = rho_"std." T_"std."/T $
#set math.equation(numbering: "(1)")
where the temperature $T$ is measured on an absolute scale.
If you have a Fahrenheit thermometer you can convert its reading to the absolute Rankine scale by adding 460°, while the reading of a Celsius ("Centigrade") thermometer is converted to the absolute Kelvin scale by adding 273°.
Strictly speaking, variations in air pressure due to changes in the weather also change the atmospheric density, but in any weather good enough for flying high-performance model rockets safely such effects are relatively minute.

Finally, the movement of a body through the air produces local changes in density, since the increased pressures on the body's surface resulting from such motion tend to compress the surrounding air.
If the motion is slow enough to keep these
// === page 24 ===
effects small, results from incompressible flow theory can be used in our analysis of drag which permit considerable simplifications over theories which take compressibility into account.
The magnitude of compression effects due to velocity can be estimated following the method of Schlichting @boundary-layer-theory.

The _modulus of elasticity_ of air, denoted by $E$, is defined by
$
  Delta p = -E (Delta V)/(V_0)
$
where $Delta V/V_0$ denotes the change in each unit volume of air produced by the change in pressure $Delta p$ .
For air at sea level, assuming isothermal (constant-temperature) pressure changes, E is just equal to the sea-level pressure of 101,325 nt/m².
The total _mass_ of air present in the volume $V_0$ must be equal to the total mass present after the pressure change has altered the volume to $V_0 + Delta V$.
Since mass is just the product of density and volume, this means
$
  (V_0 + Delta V)(rho_0 + Delta rho) = V_0 rho_0
$
Carrying out the multiplication and neglecting the products of differences in volume and density,
$ (Delta rho)/(rho_0) = -(Delta V)/(V_0) $
so that
$ Delta p = E (Delta rho)/rho_0 "or, equivalently," (Delta p)/rho_0 = (Delta rho)/E $ <eq:bulk-modulus>
Now the speed of sound, denoted by $c$, can be found by solving
// === page 25 ===
a calculus problem known as Laplace's equation, given the density and elasticity of the air.
The result of the calculation is
$ c^2 = E/(rho_0) $
Bernoulli's equation, one of the basic formulae of fluid dynamics, gives the relation between the pressure exerted by a moving fluid in the direction transverse to its motion (the _static pressure_) and the flow velocity $u$ as
$ p + 1/2 rho_o u^2 = "constant" $
The maximum change in pressure $Delta p$ caused by flow of velocity $u$ about a body is therefore (assuming there is some so-called _stagnation_ point on the body's surface at which the fluid is decelerated to rest) of the order $1/2 rho_0 u^2$.
This last quantity is often denoted by the symbol q and referred to as the _dynamic pressure_.
Substituting $E = c^2 rho_0$ and
$ Delta p ≅ 1/2 rho_o u^2 $
into @eq:bulk-modulus, we obtain
$ (Delta rho)/(rho_0) ≅ (rho_0 u^2)/(2 c^2 rho_0) = 1/2 ( u/c )^2 $ <eq:density-variation-mach>

The ratio $u/c$ is known as the _Mach number_ $M$ of the flow (named for Ernst Mach (1838-1916)).
Since, for approximate incompressibility to prevail, $Delta rho / rho_0$ must be small compared to one, @eq:density-variation-mach gives
$ 1/2 M^2 << 1 $
// === page 26 ===
If one assumes $(Delta rho) / rho_0 = 0.05$ to be the largest tolerable relative compression for which compressibility need not be considered, one derives $1/2 M^2 = .05$, or $M = 0.316$.
Since the velocity of sound at sea level (see @fig:atm-sound-speed) is about #qty("340", "m/s"), this value of Mach number corresponds to a rocket velocity of about #qty("107", "m/s").
High-performance model rockets certainly attain, and often exceed, this value in flight, but for the majority of model rockets it is a fairly high figure, attained only during the final instants of powered flight, if at all, and then persisting for only a short time after burnout.
As we shall see in @sec:transonic-supersonic-drag, moreover, slender, finned projectiles like model rockets possess the fortunate property that, throughout much of the higher subsonic flight regime, the influence of compressibility on the overall drag characteristics of the body as computed according to incompressible flow theory is relatively slight even though the relative compression itself is not.
Hence, it will be assumed throughout this chapter's Sections #ref(<sec:basic-considerations>, supplement: none) through #ref(<sec:zero-lift-drag-calc>, supplement: none) that effects due to the compressibility of air are negligible.

#figure(
  image("../../assets/figures-original/fig3-4.png"),
  caption: [Variation of standard atmospheric sound speed with altitude above sea level.]
) <fig:atm-sound-speed>

==== Viscosity and Kinematic Viscosity <sec:viscosity>
Suppose we had a cube of some elastic solid material, such as hard rubber or some "springy" metal like steel or aluminum.
Suppose, moreover, that we had somehow arranged to apply forces parallel to four faces of the cube in the manner shown in @fig:shear-solid (a).
The force on each face (which is equal in magnitude to that on each of the other faces), divided by the area of that face, is known as the _shearing stress_ $tau$,
// === page 27 ===
// Figure 4
// Figure 5
// === page 28 ===
given in MKS units as #unit("N/m^2").
Thus, if the face area is denoted by $A_C$ and the force by $F$, $tau = F/A_C$.
Since the cube is place in static equilibrium by the force system thus described, it will neither move away nor turn--but it _will deform_ into a rhomboidal parallelepiped as shown in @fig:shear-solid (b) where the angle $theta$ as illustrated is less than $90 degree$.
If the stress is reasonably small; i.e., within the so-called _elastic limit_ for the material, the cube will not be permanently bent out of shape by it, but will return to its original form when the stress is removed.
In most materials this results in the difference $(pi/2 - theta)$, where $theta$ is given in _radians_ (1 radian = $57.3 degree$), being small.
For such cases, the quantity $(pi/2 - theta)$ is defined as $gamma$, the _engineering shear strain_ which is effectively dimensionless although it is often written in units such as #unit("m/m", per: "/").
The stress required to produce a given shear strain is given by Hooke's law as
$ tau = G gamma $
where $G$, given in #unit("N/m^2", per: "/"), is called the _torsion modulus_ or _shear modulus_.
In elastic solids, then, the shearing stress is directly proportional to the _amount_ of shearing strain.
In _fluids_, however, the deformation law assumes a different dependence on strain, as the following experiment demonstrates.

#figure(
  image("../../assets/figures-original/fig3-5.png"),
  caption: [Shearing deformation of an elastic solid.
  A cube of elastic material is subjected to a shearing stress $tau$ ($tau = F/A_c$) on its lateral faces (a), placing it in a state of uniform shearing strain $gamma$ ($gamma = pi/2 - theta$) as shown in (b).
  The cube is viewed directly from the front, so that only its forward face is visible.]
) <fig:shear-solid>

Consider two very long parallel plates, containing a viscous fluid between them (the meaning of "viscous" will become clear as the experiment proceeds), as in @fig:shear-fluid (after @boundary-layer-theory).
The lower plate is fixed in the observer's reference frame, while the upper plate, at a height $h$ above the lower, moves to the
// === page 29 ===
// Figure 6
// === page 30 ===
right with a constant velocity $U$.

#figure(
  image("../../assets/figures-original/fig3-6.png"),
  caption: [Shearing deformation of a viscous fluid.
  The lower plate is fixed, while the upper plate moves at horizontal velocity U.
  The horizontal velocity of the fluid confined between the plates is given by $u = U y/h$.]
) <fig:shear-fluid>

An extremely important experimental observation about viscous fluid flow is that the fluid behaves as if it were _adhering_ to any surface with which it comes in contact--that is, the fluid directly adjacent to any given surface undergoes no relative motion with respect to that surface; it "sticks" to it.
This phenomenon, known as the no-slip condition at the wall, means that the material of which the plates are constructed is immaterial to the flow (assuming hydraulically smooth surfaces).
The no-slip condition is a useful physical assumption in continuum fluid dynamics, although it is by no means an absolutely valid physical model of what actually happens near a surface in fluid flow.
In fact, there are cases of the flow of extremely rarified gases in which a considerable amount of "slip" relative to the wall occurs and a finite-slip condition must be applied.
In all cases of interest to model rocketeers, however, the validity of the no-slip condition can be assumed.
The no-slip condition has a number of ramifications in application to model rockets which will be detailed in @sec:viscous-drag.

In our experiment, a consequence of the no-slip condition is that the velocity of the fluid increases linearly with height above the lower plate, from zero at the lower plate to U at the upper plate.
Assuming the lower plate to be fastened to some fixture that prevents it from moving, there must be a force $F$ applied tangentially to the upper plate to _maintain_ its velocity at $U$, and since there is no acceleration $F$ must equal the frictional (or _viscous_) forces applied to the upper plate by the fluid.
Furthermore, experiment reveals that
// === page 31 ===
$ F prop (U A)/h $
where A is the area of the upper plate in contact with the fluid.
The frictional shearing stress $tau$ is then proportional to $U/h$.
Since the fluid velocity varies linearly with $y$, the vertical coordinate, $U/h$ is just equal to the rate at which the fluid velocity $u$ increases with height above the lower plate; i.e., the derivative of $u$ with respect to $y$, or $(dif u)/(dif y)$.
Thus,
#set math.equation(numbering: _ => "(12a)")
$ tau prop dif u/dif y $ <eq:viscosity-proportional>
where the symbol $prop$ reads in English, "is directly proportional to".
Specifically, it has been found that
#set math.equation(numbering: _ => "(12b)")
$ tau = mu (dif u)/(dif y) $ <eq:newtons-viscosity>
#counter(math.equation).update(12)
#set math.equation(numbering: "(1)")
where $mu$ is the _coefficient of viscosity_, a physical property of the fluid.
From (@eq:newtons-viscosity) it is seen that the shearing stress in a fluid is dependent on the _rate_, not the _amount_ of deformation.

The constant $mu$ is then a measure of a fluid's resistance to deformation.
At room temperature, water is roughly 75 times as viscous as air.
Substances like glycerine and molasses are more viscous still.
Thus you can see that the word "thick", as applied to fluids colloquially, is roughly equivalent to the more technical term "viscous".
For gases, to a first approximation, $mu$ can be considered independent of pressure, depending only on temperature.
In @fig:atm-viscosity, $mu$ is seen to decrease steadily with increasing altitude.

#figure(
  image("../../assets/figures-original/fig3-7.png"),
  caption: [Variation of the absolute viscosity of standard atmosphere with altitude above sea level.]
) <fig:atm-viscosity>

The ratio of the coefficient of viscosity to the density of a fluid is called its _kinematic viscosity_ $nu = mu/rho$.
It is
// === page 32 ===
// Figure 7
// === page 33 ===
// Figure 8
// === page 34 ===
this quantity, rather than $rho$ independently, that will appear repeatedly in our analysis of drag; its significance is discussed in the treatment of Reynolds number.
For the present, we observe from @fig:atm-kinematic-viscosity that $nu$ increases relatively slowly with altitude.
This is because at altitudes typical of model rocket flight, although $rho$ and $mu$ are both decreasing, $rho$ is decreasing at a faster rate than $mu$ with increasing altitude.
At an altitude of #qty("300", "m"), $nu$ is only about 2.4% greater than its sea-level value.
In the calculations of this chapter $nu$ will be assumed to have a constant value of #qty("1.495e-5", "m^2/s"), an average valid for the temperature and density variations normally encountered in flying model rockets.

#figure(
  image("../../assets/figures-original/fig3-8.png"),
  caption: [Variation of the kinematic viscosity of standard atmosphere with altitude above sea level.]
) <fig:atm-kinematic-viscosity>

=== Dimensionless Coefficients and Quantities <sec:dimensionless-coefficients>
==== The Reynolds Number <sec:reynolds-number>
 In our study of model rocket drag, we will make frequent use of a dimensionless quantity called the _Reynolds number_, denoted by R.
Named for the English physicist Osborne Reynolds (1842-1912), its value reflects the nature of the flow about a body.
Under certain conditions the drag coefficient (see @sec:drag-coefficient) may be expressed as a function of Reynolds number alone.

The theoretical derivation of the Reynolds number may be accomplished in a variety of ways: by dimensional analysis, by a consideration of the forces acting on a fluid element in incompressible flow, or by examination of the Navier-Stokes equations of fluid equilibrium.
I shall use the second approach, since I feel it is of greatest interest to model rocketeers; those readers who desire to follow the other lines of argument
// === page 35 ===
are referred to the excellent accounts in Shapiro @shape-and-flow and Schlichting @boundary-layer-theory.

Suppose we consider the forces acting on a fluid element moving parallel to the x-axis of a Cartesian coordinate system at a velocity u, where u is a function of both the x and y coordinate values (@fig:fluid-element).
The size of the fluid element is large compared with the dimensions of a molecule of fluid, and large compared with the average distance between the molecules, but small compared with the dimensions of the region in which fluid is flowing and small compared to the dimensions of any physical boundary or solid object nearby.
The flow itself is composed of a very large number of fluid elements, such that variations in density, velocity, and all other physical properties between adjacent elements are small enough to permit the flow to appear continuous.

#figure(
  image("../../assets/figures-original/fig3-9.png"),
  caption: [A fluid element in Cartesian coordinates, showing the variation of the x-component of velocity with the y coordinate and the shearing stress on the upper and lower y-faces of the element.]
) <fig:fluid-element>

There are essentially two types of forces which act upon an individual fluid element: _body_ forces, which act from a distance (such as gravity), and _surface_ forces, which act through the physical contact of one fluid element with another.
Surface forces may be further subdivided into _normal_ stresses (pressure), which act perpendicular to the surface, and _shear_ stresses (viscous friction), which act parallel to the surface of the element.

In this analysis, the body force due to gravity is assumed to be balanced by buoyancy forces in the fluid, and hence is neglected.
Furthermore, the fluid is assumed incompressible, which means that the volume of each fluid element is constant;
// === page 36 ===
// Figure 9

// Figure 10
// === page 37 ===
hence any elastic forces which might arise from a change in volume are neglected.

The only forces left to consider, then, are _inertia_ forces and _viscous_ friction forces.
We shall attempt to express the ratio of these two forces in terms of the variables which determine the nature of the flow: the density $rho$, the coefficient of viscosity $mu$, the free-stream velocity $V$, and a characteristic linear dimension of any given solid body in the flow, $L$.

The free-stream velocity $V$ is the velocity of the undisturbed fluid relative to the solid body.
For a model rocket, $V$ is the velocity of the airstream as seen by an imaginary observer moving with the rocket, at points far enough from the rocket's surface to be undisturbed by its passage (@fig:free-stream-velocity).
It is important to distinguish $V$ from the velocity of elements very near the body; for the elements at the surface itself this velocity is effectively zero.
In most cases applicable to model rockets, $L$ will refer to the total length of the rocket.
When we consider friction drag in @sec:viscous-drag, however, we will find that the nature of the flow over the fins is determined by the fin chord $c$, so $L$ will be taken as $c$ in that instance.

#figure(
  image("../../assets/figures-original/fig3-10.png"),
  caption: [The concept of free-stream velocity.
  The air in the free stream moves past the rocket at velocity $V$, while the air in the "boundary layer" next to the rocket's surface is slowed down by viscous friction.
  The thickness of the boundary layer has been greatly exaggerated to make it visible; actual boundary layers have thicknesses on the order of $10^(-2)$ or $10^(-3)$ cm.]
) <fig:free-stream-velocity>

From considering @fig:fluid-element, one can determine that the net resultant of all shearing forces on the element is
$ (tau + (partial tau)/(partial y) dif y) dif x dif z - tau dif x dif z = (partial tau)/(partial y) dif x dif y dif z $
Applying @eq:newtons-viscosity and dividing through by $dif x dif y dif z$, the volume of the element, we find the shear force per unit volume as
// === page 38 ===
$ (partial tau) / (partial y) = mu (partial^2 mu) / (partial y^2) $
Note that the symbol $partial$, rather than $dif$, is used in writing the derivatives of a function of more than one independent variable.
The derivative of such a function is called a _partial derivative_.
The inertia force per unit volume, assuming steady (i.e., not oscillating) flow conditions, is equal to $rho u (partial u)/(partial x)$.
Consequently,
$ ("inertia force")/("friction force") = (rho u (partial u)/(partial x))/(mu (partial^2 u)/(partial y^2)) $
Now using order-of-magnitude approximations, we can say that the velocity $u$ is of the same order of magnitude as the free stream velocity $V$, $(partial u)/(partial x)$ is of the order $V/L$, and $(partial^2 u)/(partial y^2)$ is of the order $V/L^2$.
Hence the ratio of inertia force to friction force is given approximately by
$ ("inertia force")/("friction force") = (rho (V^2)/L)/(mu V/L^2) = rho/mu V L = (V L)/nu $ <eq:inertia-to-friction>

The quantity $(V L)/nu$ is the Reynolds number.
Part of the significance of this quantity (which is dimensionless when evaluated in a consistent set of units) stems from the answer to the following question: given two bodies, geometrically similar but of different sizes, what is the condition that must be satisfied for the _flow_ over these two bodies to be similar; i.e., for the streamlines to be geometrically similar also?
Some thought reveals that the forces acting on any two fluid elements at geometrically similar positions must bear the same ratio in both cases, at each and every instant of time.

If we consider now the type of flow from which we derived
// === page 39 ===
the Reynolds number; i.e., an incompressible flow with no free surfaces (so that gravity and buoyancy forces cancel) it is apparent that the inertial and viscous forces bear a fixed ratio in any two cases of flow about geometrically similar bodies _if the Reynolds numbers of the two flows are identical_.
Two such flows are referred to as _dynamically similar_.

To illustrate this principle by example, consider the airflow about the Saturn V moon rocket and that about an accurate 1/100 scale model of that vehicle.
For the flow about the two bodies to be dynamically similar, the Reynolds numbers must be equal; hence
$ ( "v L"/nu )_("full-scale") = ("v L"/nu )_("model") $ <eq:reynolds-similarity>
Since the fluid is air in both cases, and we can restrict the problem to low-altitude flight with standard launch-site atmospheric conditions, the values of $nu$ are identical.
With $L_("full-scale") = L_("model") times 100$, the requirement of equal Reynolds numbers becomes
#set math.equation(numbering: none)
$ V_("model") = 100 V_("full-scale") $
#set math.equation(numbering: "(1)")

The airflow about the model Saturn #conflict("V") flying at, say, 100 meters/second is then dynamically similar to that about the full-scale rocket when it is moving only one meter/second!
Throughout almost all of its flight, the full-scale Saturn V is in a Reynolds number regime far above that which model rockets ever experience.
This suggests that the types of flow problems encountered in model rocketry tend to be somewhat different from those of full-
// === page 40 ===
scale astronautics--a conclusion which, to a large degree, is correct.

The principle of dynamic similarity is the basis for the technique of model testing, whether by wind tunnel or any other means.
To achieve the same flow characteristics about a scale model which are found at typical operating velocities about the full-scale version, it is possible to vary both the test velocity and the kinematic viscosity, as seen in @eq:reynolds-similarity.
Practically speaking, the velocity of a wind tunnel cannot be made large enough to attain the desired Reynolds number if the disparity in size between model and prototype is too great.
For instance, the subsonic aerodynamic characteristics of the Saturn V could not be determined by the wind-tunnel testing of a 1/100 scale model, since simulation of a prototype velocity of 100 meters/second would require a wind-tunnel test at 10,000 meters/second; and while the Reynolds numbers would then be equal the extreme compressibility effects on the model test would destroy its validity.
By choosing another test fluid with a lower value of $nu$, however, it is possible to conduct dynamically similar model tests for moderate scaling ratios between model and prototype.
Water, for instance, has a kinematic viscosity at room temperature less than 8% that of air; it would therefore be possible to test a 1/4 scale model of a light airplane which is to fly 45 meters/second, using a test velocity of 15 meters/second in water, and have flow about the model which is dynamically similar to that about the full-scale airplane.
Increasing the model size has the same effect as reducing the kinematic viscosity:
// === page 41 ===
it permits dynamically similar testing at lower velocities.
For this reason, many wind tunnels are built today with very large test-section dimensions.

To get an idea of the Reynolds numbers commonly encountered in model rocketry, suppose we compute the value of $R$ for a model 0.3 meter long travelling at 60 meters/second.
Using $nu$ = #qty("1.495e-5", "m^2/s"), we obtain from @eq:inertia-to-friction $R$ = #num("1.205e6").
Because a consistent set of units was used, the Reynolds number is dimensionless; this must be the case, as the ratio of forces should not depend on the system of units used to evaluate it.

It appears that model rocket flight thus enters regimes in which inertia forces on the air in regions surrounding the model are about a million times greater than frictional forces.
One might assume, for this reason, that it would be possible to ignore friction forces completely in our analysis.
Despite the attractiveness of this proposition, it does not stand up to experiment; friction forces exert a great influence on the flow around a body, no matter how great the Reynolds number, but their action is confined essentially to a very thin layer at the body's surface known as the _boundary layer_.
This concept will be discussed more thoroughly in @sec:viscous-drag.

==== The Drag Coefficient <sec:drag-coefficient>
The drag coefficient of a body, denoted by $C_D$, is defined as
$ C_D = D/(1/2 rho V^2 A_r) $ <eq:18>
// === page 42 ===
where $D$ is the drag force, $A_r$ is a characteristic "reference area" of the body (in model rockets, usually the body tube cross-sectional area), and $1/2 rho V^2$ is known as the _dynamic pressure_.
In this form, evaluated with a consistent set of units, the drag coefficient is dimensionless.

Under certain conditions the drag coefficient possesses a very useful and valuable property: given two geometrically similar bodies, the only difference in drag coefficient between them (if any) will be due to their being operated at different Reynolds numbers; the drag coefficient is a _function of Reynolds number alone_.
Mathematically,
$ C_D = f(R) $ <eq:cd-function-of-reynolds>
Conditions required for the validity of @eq:cd-function-of-reynolds, in addition to geometric similarity, are that the flow be incompressible and the angle of attack be zero, so that the only forces acting on a fluid element in the vicinity of the body are due to friction and inertia.
The functional dependence of $C_D$ on $R$ must usually be determined experimentally, as present theory is generally inadequate to predict drag coefficients for any but the simplest geometric shapes.
For the model rocketeer, this would imply the necessity for extensive wind tunnel tests on each of his models.
Unfortunately, there are few individuals with access to the necessary equipment for such tests.

One solution to this problem is to resort to semi-empirical expressions for the drag coefficient which have been compiled from statistics derived by testing a great many subsonic rocket
// === page 43 ===
vehicles.
In @sec:zero-lift-drag-calc, one such method is presented and analyzed in detail.
Although these formulae are not applicable to bizarre model rocket shapes, and have not yet been extended to multistaged vehicles with any considerable degree of confidence in their accuracy, they do permit sizeable variations in nose cone shape, fin planform, number of fins, boattail characteristics, and general physical dimensions for single-stage rockets.

Since the empirical expression must necessarily be dependent on Reynolds number, it would appear that a laborious computational procedure is still required to determine graphically the relationship between $C_D$ and $R$ for any given model.
Fortunately, as we shall see later, the drag force on a model rocket over a considerable range of Reynolds numbers of interest is very nearly proportional to the square of the velocity:
$ D = k V^2 $
where $k$ is a constant.
Comparison of #conflict("equation (2.20) with equation (2.18)") reveals that $k$ is just equal to $1/2 rho C_D A_r$, so that the condition of constant $k$ requires
$ C_D = "constant" $
Hence, to obtain a drag coefficient of acceptable accuracy for almost all model rocketry purposes it is necessary to calculate only a single value of $C_D$ from the semiempirical expression, using a Reynolds number roughly estimated as the average value to be encountered in flight.
The "average" $C_D$ thus determined may then be used in performance analyses.
// === page 44 ===
==== The Coefficient of Pressure <sec:pressure-coefficient>
Undisturbed air has an _ambient_, or "static", pressure (denoted $p_0$) which may be measured on a gauge or barometer.
At sea level, the ambient pressure is equal to #qty(101325, "N/m^2").
In flow past a body such as a model rocket, however, the static pressure as measured on a gauge by an imaginary observer moving with the airstream will be seen to undergo changes in value.
At a _stagnation point_ (where the flow has been brought to rest relative to the body, as happens at the tip of the nose), for example, the static pressure will increase.
In incompressible flow the amount of this increase is just $q = 1/2 rho V^2$, where $V$ is the free-stream velocity.
At other points on the body, the static pressure will vary between its value at the stagnation point#conflict("--")$(p_s)_("stag") = p_0 + 1/2 rho V^2$#conflict("--")and some minimum value which _can_ be _less_ than the ambient static pressure $p_0$.

The fundamental relationship which relates changes in static pressure to changes in dynamic pressure $q$ is _Bernoulli's Principle_, which states that the total pressure $P_("tot")$ is a constant in frictionless, incompressible flow.
The total pressure is simply the sum of the local static and dynamic pressures, at any location in the flow:
$ P_("tot") = p_(s 1) + 1/2 rho u_1^2 = p_(s 2) + 1/2 rho u_2^2 = "constant" $ <eq:total-pressure>
where $p_(s 1)$, $p_(s 2)$, and $u_1$, $u_2$ are the static pressures and velocities at any two points which have been designated point 1 and point 2, respectively.
If we choose point 1 to be a stagnation point, $u_1$ is zero and
// === page 45 ===
$ p_("tot") = (p_s)_("stag") = p_s + 1/2 rho u^2 = "constant" $ <eq:total-pressure-stagnation>
The total pressure of the flow is thus seen to be equal to the static pressure at a stagnation point.

The increment in static pressure at stagnation, $q = 1/2 rho V^2$, is an important quantity in aerodynamics, as in many applications the force experienced by an object resulting from the flow of fluid around it is proportional to $q$.
This explains, for instance, why the drag coefficient is defined as
$ C_D equiv D/(q A_r) $
In an analogous manner we can define a _pressure coefficient_.
It is apparent from the above discussion that _differences_ in pressure, rather than absolute pressures, are important in determining fluid dynamic forces.
Hence we define
$ C_p equiv (Delta p)/q equiv (p - p_(infinity))/q $ <eq:pressure-coefficient>
where $p$ is the local static pressure, $p_(infinity)$ is the ambient atmospheric pressure (free-stream static pressure)--#qty(101325, "N/m^2") at sea level--and $q$ is the free-stream dynamic pressure, $1/2 rho V^2$.
At a stagnation point, @sec:pressure-coefficient gives the result $C_p = +1.0$.

In @sec:pressure-drag, Bernoulli's Principle and the concept of the pressure coefficient will be used to explain the existence of pressure drag.

=== Constituents of the Total Drag Coefficient <sec:drag-constituents>
It has been found in practice that a systematic analysis of drag requires some scheme for dividing the drag into components,
// === page 46 ===
which can then be studied separately.
In subsonic flow problems, the most common partitioning technique is to divide the total drag into _skin-friction drag_ (due to forces tangential to the body surface) and _pressure drag_ (resulting from forces perpendicular to the body surface).
Integration of the _components_ of the tangential and normal forces which are _parallel to the direction of motion_ leads to the following general expressions for the drag @missile-aerodynamics:

// Terms List
// / pressure drag: $ D_p = - integral.double_S p cos(arrow(n), arrow(V)) dif S $

// / skin-friction drag: $ D_v = integral.double_S tau cos(arrow(t), arrow(V)) dif S $

// Grid --- Not satisfied with this approach yet
#align(center)[
  #grid(
    columns: (1fr, 2fr),
    align: (right + horizon, left + horizon),
    column-gutter: 2em,
    row-gutter: 1em,
    [pressure drag:], [$ D_p = - integral.double_S p cos(arrow(n), arrow(V)) dif S $ <eq:pressure-drag>],
    [skin-friction drag:], [$ D_v = integral.double_S tau cos(arrow(t), arrow(V)) dif S $ <eq:skin-friction-drag>]
  )
]

The notation associated with these so-called _double integrals_ or _surface integrals_ is illustrated in @fig:surface-integral-notation.
The effect of performing the calculus operation called "integration" is just to add up all the infinitesimal contributions to drag resulting from the pressure and viscous skin-friction stress on each infinitesimal bit of surface area $dif S$.
The pressure integration results in @eq:pressure-drag, while the friction integration results in @eq:skin-friction-drag.
The area $S$ includes the base area of the rocket.

#figure(
  image("../../assets/figures-original/fig3-11.png"),
  caption: [Notation used in the surface integrations for calculating friction drag and pressure drag.
  The unit vector $arrow(n)$, perpendicular to the surface, and the unit vector $arrow(t)$, tangent to the surface, originate from the center of the small element of area $dif S$.
  The notation $cos(arrow(n), arrow(V))$ refers to the cosine of the angle between $arrow(n)$ and $arrow(V)$, while $cos(arrow(t), arrow(V))$ is the cosine of the angle between $arrow(t)$ and $arrow(V)$.]
) <fig:surface-integral-notation>

The pressure drag may be further subdivided into the integral over the base area, called _base drag_, and the integral over the rest of the model's surface, called _pressure foredrag_:
$ D_p = - integral.double_(S_b) p cos (arrow(n), arrow(V)) dif S_b - integral.double_(S_S) p cos (arrow(n), arrow(V)) dif S_s $ <eq:pressure-drag-expanded>
where $S_b$ denotes the base area and $S_s$ the total forebody surface, or "wetted", area.
@eq:pressure-drag-expanded may also be written using
// === page 47 ===
// Figure 11
// The drag force on a model rocket over a considerable range of Reynolds numbers is nearly proportional to the square of the velocity:
// $ D = k V^2 $
// where $k$ is a constant.
// Comparison of equation (2.20) with equation (2.18) reveals that $k$ is just equal to $1/2 C_D A_r$, so that the condition of constant $k$ requires
// $ C_D = "constant" $
// where $C_D$ is the drag coefficient.
// === page 48 ===
the abbreviated notation
$ D_p = D_b + D_f $
where $D_b$ denotes the base drag and $D_f$ the pressure foredrag.
This arrangement is convenient because base drag is an important topic in itself, and special techniques are employed to reduce it.
The total drag at zero angle of attack is then
$ D = D_b + D_f + D_v $

Skin friction drag is discussed in @sec:viscous-drag, and base drag in @sec:pressure-drag.
The analysis of these sections will be valid only for zero angle of attack; in @sec:other-drag, the additional drag $D_alpha$ due to angular deflection of the rocket longitudinal axis from the direction of the relative airstream will be considered.
The total drag at a general, nonzero angle of attack may then be written
$ D = D_b + D_f + D_v + D_alpha $

Dividing by $1/2 rho V^2 A_r$, where the $A_r$ we will be using is the rocket's _maximum frontal area_, we can express the drag in nondimensional form as the sum of constituent drag coefficients:
$ D/(1/2 rho V^2 A_r) = C_D = C_D_b + C_D_f + C_D_v + C_D_alpha $ <eq:total-drag-coefficient>
You should note the use of maximum cross-sectional area in this chapter for computing drag coefficients, as opposed to the use of the cross-sectional area at the base of the nose as the reference area for determining the normal force coefficients of #conflict("Chapter 2's") Barrowman analysis.

// === page 49 ===
The above scheme of componentization will be used to study model rocket drag in succeeding sections.
At this point something might be said about the relative importance of the various terms in @eq:total-drag-coefficient.
According to experimental evidence to date, the order of importance of the drag components of a typical streamlined, well-constructed model rocket might appear as follows:

+ _Launch lug drag_: In models having launch lugs, the lug produces a component of pressure drag that must be added to the pressure foredrag.
  This component accounts for about 35% of the total $C_D$.
+ _Skin-friction drag of forebody_: Accounts for 25% to 30% of the total $C_D$ in models having launch lugs, 35% to 45% in lugless models.
+ _Skin-friction drag of fins_: Accounts for 25%-30% of the total $C_D$ in models with lugs, 35%-45% in lugless models.
+ _Base drag_: Accounts for about 10% of the total $C_D$ in models having lugs, about 15% in lugless models.
+ _Pressure foredrag_: Forebody pressure drag from sources other than launch lugs accounts for less than 1% of the total $C_D$.

The order of this list, and the relative magnitudes of the contributions, can be altered drastically by improper construction techniques.
Failing to provide the fins with the
// === page 50 ===
proper airfoil shape gives rise to a pressure drag several times greater than the _total_ drag would be with properly-shaped fins.
Rough surface finishes and blunt nosecones also lead to considerable increases in drag, though not so great as do unshaped fins, and the increase in drag due to nonzero angle of attack can be quite large even for a well-streamlined vehicle.
It is not uncommon for a model rocket to have twice the drag at a 10° angle of attack that it exhibits at 0°.

Typical values of the total drag coefficient for model rockets with launch lugs range from 0.5 to 0.8, depending on the quality of the design and construction of the model.
By comparison, a circular disc held perpendicular to the flow has a $C_D$ of 1.1; the disc thus experiences a drag force 50% to 100% greater than that on a model rocket of the same diameter in an airstream of the same velocity.
This result foreshadows our later discussion on the undesirability of blunt shapes and abrupt protrusions in model rocket work.
To quote an example, removing the launch lug from a certain model rocket may reduce its drag coefficient from 0.7 to about 0.45.

@fig:drag-constituents summarizes diagrammatically the important topics in model rocket drag to be considered in detail in the following pages.

#figure(
  image("../../assets/figures-original/fig3-12.png"),
  caption: [Causes and constituents of model rocket drag.
  The various drag constituents and flow phenomena shown here are discussed in detail in later sections of this chapter.
  The thickness of the boundary layer in this drawing has been greatly exaggerated to make it visible to the eye.]
) <fig:drag-constituents>

== Viscous (Skin-Friction) Drag <sec:viscous-drag>

=== The Importance of Viscosity in Real Fluid Flow <sec:viscosity-importance>

In @sec:basic-concepts the skin-friction drag was defined as
$ D_v = integral.double_S tau_0 cos(arrow(t), arrow(V)) dif S $
// === page 51 ===
// Figure 12
// === page 52 ===
where $tau_0$ is the skin-friction force per unit area at the surface of the model (equal to the viscous shearing stress in the air directly adjacent to the model surface).
Recalling @eq:newtons-viscosity, we can write $tau_0$ as
$ tau_0 = mu ( (partial u)/(partial y) )_(y=0) $ <eq:wall-shear-stress>
where we have adopted a "local" coordinate system in which the y-axis extends perpendicularly upwards from the point on the rocket's surface at which $tau_0$ is being evaluated.
Earlier we saw, via an estimate of typical model rocket Reynolds numbers, that inertial forces are about a million times greater than viscous forces at average model rocket flight speeds.
Why, then, not ignore the viscous forces completely in our analysis?

The mathematical model which corresponds to this assumption is the so-called "perfect fluid" of classical hydrodynamics.
The theory of the perfect fluid model, which assumes a fluid that is incompressible and has a coefficient of viscosity of zero, was well developed before the beginning of the 20th Century since the mathematical simplifications permitted by the perfect fluid assumption are considerable.
The results one obtains from calculations based on classical hydrodynamics, however, assert that the drag on a closed body of _any shape_ moving at constant velocity through a perfect fluid is exactly _zero_.
This prediction was so contradictory to all experimental evidence--even that available in the mid-19th Century--that it came to be called d'Alembert's Paradox.
It was apparent that one of the fundamental assumptions of the ideal fluid
// === page 53 ===
theory was physically inaccurate.

In 1904 the great German scientist Ludwig Prandtl (1875-1953) resolved this dilemma by introducing the concept of the _boundary layer_.
According to this theory, the influence of viscosity in fluids whose viscosity is small (or in situations where the Reynolds number is large) is confined to a thin region near the surface of any solid body immersed in the flow.
The fluid obeys the rule of _no slip_ at the wall--contrary to the behavior of the perfect fluid, which was allowed to flow past a body freely--and hence the fluid velocity must increase from zero at the body wall to the full free-stream value in a very short distance, perhaps a few hundredths or thousandths of a centimeter (note that the terms "wall" and "surface" are being used interchangeably in this discussion).
This condition requires that the fluid velocity increase very rapidly with distance from the body surface; i.e., that the _velocity gradient_ $(partial u)/(partial y)$ be very large in the boundary layer, and hence $tau_0$ in @eq:wall-shear-stress may _not_ be negligible even if $mu$ is small.

This theory essentially divides the flow about a body at high Reynolds numbers into two regions.
Within the thin boundary layer viscous forces are of about the same magnitude as inertial forces, and hence cannot be ignored.
Outside the boundary layer, the flow conforms very closely to the behavior of a perfect fluid: frictional forces are negligible in this region.
This partitioning of the flow permits a mathematical solution to the problem of flow about a body at high Reynolds numbers to be obtained.
This is generally done by first
// === page 54 ===
determining the flow about the body by the methods of classical hydrodynamics--the so-called "potential flow" theory.
The solution thus obtained for the flow outside the boundary layer provides what mathematicians call "boundary conditions" which allow the solution of the boundary-layer equations to be carried out.
The two solutions are then "grafted together" where the boundary layer ends and the outer flow begins, to provide a picture of the total flow pattern.

The mathematical difficulties involved in the solution of a three-dimensional boundary layer, as on a model rocket, are nevertheless of momentous proportion.
Several basic problems, such as the location of the "transition point" where the character of the boundary-layer flow changes from "laminar" to "turbulent" (these terms will be discussed in detail later on), as yet lack a firm theoretical foundation for their solution.
Furthermore, it is doubtful whether a complete mathematical description of the flow pattern about his model would be of great benefit to the hobbyist, as such a description can only be obtained by laborious numerical techniques requiring the use of an electronic computer for each and every case to be solved.

This section will therefore confine itself to a discussion of the basic concepts of boundary-layer theory likely to be of greatest interest and utility to the model rocketeer.
The ultimate aim, of course, is to develop expressions for the viscous stresses in the boundary layer which can be related directly to the skin-friction drag.
Fortunately, with the aid of certain assumptions which will be enumerated as we go on,
// === page 55 ===
one _can_ derive results which are applicable to the calculation of skin-friction drag on model rockets.

=== The Distinction Between Laminar and Turbulent Flow <sec:laminar-turbulent>
The fluid flow within a boundary layer may be characterized as either _laminar_ or _turbulent_.
The distinction between these two states may be observed in the stream of smoke rising from a burning cigarette in very still air (@plate:laminar-turbulent-smoke).
For a short vertical distance the column is narrow and straight, but above this region the flow disintegrates into a disorderly, eddying stream.
The smooth, unmixed phase of the flow is termed _laminar_; the rough, eddying part is called _turbulent_.

#figure(
  image("../../assets/figures-original/plate3-1.png"),
  kind: "plate",
  supplement: [Plate],
  caption: [Smoke rising from a cigarette in a still room.
  The path of the smoke is at first smooth and straight (laminar flow), but after it has risen for a certain distance it becomes rough and mixed (turbulent flow).]
) <plate:laminar-turbulent-smoke>

Whether the flow in the boundary layer along an object will be laminar or turbulent depends to a large extent on the Reynolds number, although physical conditions such as air turbulence and surface roughness can assume important roles.
Experimentally, the value of $R$ at which the transition from laminar to turbulent flow in the boundary layer over a flat plate will occur has been found to lie in the range between $3 times 10^5$ and $3 times 10^6$ @boundary-layer-theory.
Since this interval includes the previously calculated typical value of $R$ for a small model rocket, we may expect both laminar and turbulent boundary-layer flows to exist on model rockets during flight, depending on the velocity.

Consequently, we shall examine both types of boundary-layer flow.
Because the analysis for a three-dimensional body can be extremely complicated, our discussion will be
// === page 56 ===
// Plate 1
// === page 57 ===
restricted to the steady, two-dimensional flow past a thin, flat plate held parallel to the airstream.
Although this is geometrically a quite simple case, the skin-friction coefficients derived from the analysis of the flat plate in laminar and turbulent flow form the basis for the calculation of skin-friction drag on all three-dimensional shapes (assuming that boundary-layer separation, discussed in @sec:bl-separation, is not present).
The results of Sections #ref(<sec:laminar-boundary-layer>, supplement: none) and #ref(<sec:turbulent-boundary-layer>, supplement: none) for laminar and turbulent flow, respectively, will be used extensively later on in this chapter for the determination of model rocket drag coefficients.

Next, in @sec:bl-transition, a discussion of the mechanism of boundary-layer transition is presented.
Since laminar and turbulent boundary layers produce markedly different skin-friction coefficients, even at identical Reynolds numbers, it is important to know the location of the transition zone in order to calculate viscous drag accurately.
This problem, unfortunately, has not as yet been well-researched for model rockets, and it is necessary to assume a location for the transition.
@sec:bl-transition analyzes the important factors affecting the location of the transition point and discusses the calculation of the total skin-friction coefficient for boundary layers exhibiting both laminar and turbulent regions.

@sec:viscous-drag will conclude with some estimates of the correction factors required to apply the flat-plate results to three-dimensional configurations.
This will be seen to be small, usually 5% or less, for the fins and body of a model rocket.
// === page 58 ===
// Reviewed up to here
=== The Laminar Boundary Layer on a Smooth, Flat Plate <sec:laminar-boundary-layer>
In laminar flow, the fluid elements move parallel to the surface of the body and there is little or no mixing of the fluid--i.e., transfer of momentum--between adjacent streamlines.
Historically, the first application of Prandtl's boundary-layer theory was accomplished by H. Blasius, who in 1908 computed the laminar boundary layer in uniform potential flow past a flat plate.
Since this example illustrates many of the important features of boundary-layer analysis, we shall examine it in detail.

Steady fluid motion about such a plate is depicted in @plate:flat-plate-flow @applied-hydro-aeromechanics.
The streamlines of the flow were made visible by sprinkling aluminum particles on the water; the length of the streaks left by the particles is proportional to their velocity.
Very near the surface of the plate, the traces are much shorter than in the exterior flow; this region of reduced velocity is the boundary layer.
Note also that the apparent thickness of the boundary layer, which we shall shortly define in mathematical terms, increases with distance downstream along the plate.
This is because the boundary-layer shearing stresses are retarding a greater volume of fluid as distance from the leading edge increases.

#figure(
  image("../../assets/figures-original/plate3-2.png"),
  kind: "plate",
  supplement: [Plate],
  caption: [Flow about a thin plate of length $ell$ at a Reynolds number $R_ell$ of 3.]
) <plate:flat-plate-flow>

Note that there is no indication of the absolute size of the plate in the photograph.
Hence we expect the velocity profiles (see @fig:laminar-velocity-profiles) at all x-stations on the plate to be mathematically similar; i.e., the dimensionless ratio $u/U_(infinity)$ may be expressed as some function of the dimensionless coordinate
// === page 59 ===
// Plate 2
// Figure 13
// === page 60 ===
ratio $y/delta$, where $U_(infinity)$ is the velocity of the exterior flow immediately outside the boundary layer (calculated by potential-flow theory) and $delta$ is the boundary-layer thickness at any given location on the plate.
This function must be the same at all distances $x$ from the leading edge of the plate, although $delta$ itself becomes greater as $x$ increases.

#figure(
  image("../../assets/figures-original/fig3-13.png"),
  caption: [Profiles of longitudinal velocity in a laminar boundary layer over one side of a flat plate at zero angle of attack.]
) <fig:laminar-velocity-profiles>

We can make an estimate of the boundary-layer thickness $delta$ by equating the viscous and inertial forces within the boundary layer and solving for the value of $delta$ at which this condition occurs.
As seen in @sec:dimensionless-coefficients, the inertial forces in the fluid flowing near an object of characteristic dimension $L$ are of the order $rho U_(infinity)^2 / L$.
The friction forces per unit volume in a boundary layer of thickness $delta$ are of the order $mu U_(infinity) / delta^2$, as the velocity gradient $(partial u)/(partial y)$ exists only within the thickness of the boundary layer itself.
We then obtain
$ (mu U_(infinity))/(delta^2) tilde (rho U_(infinity)^2)/L $
Solving for the boundary-layer thickness $delta$,
$ delta tilde sqrt((mu L)/(rho U_(infinity))) = sqrt((nu L)/U_(infinity)) $
In the case of the flat plate the characteristic length of interest is the distance from the leading edge $x$.
Substituting $x$ for $L$, we obtain the boundary-layer thickness as
$ delta tilde sqrt((nu x)/U_(infinity)) $ <eq:boundary-layer-thickness>

The thickness of the boundary layer is thus seen to vary with the square root of the distance from the leading edge.
// === page 61 ===
The object of a mathematical solution to this problem is to obtain the constant of proportionality in the expression for $delta$, and to determine functions for the boundary-layer velocity profile and the skin-friction drag.

The equations of fluid flow for a general, two-dimensional boundary layer are
$ (partial u)/(partial t) + u (partial u)/(partial x) + v (partial u)/(partial y) = -1/(rho) (dif p)/(dif x) + nu (partial^2 u)/(partial y^2) $ <eq:boundary-layer-momentum>
$ (partial u)/(partial x) + (partial v)/(partial y) = 0 $ <eq:boundary-layer-continuity>
where $u$ and $v$ are the local components of velocity in the $x$- and $y$-directions, respectively.
The boundary conditions required to completely define the solution to this set of equations are
#grid(
  columns: (auto, auto, auto),
  column-gutter: 1em,
  row-gutter: 0.65em,
  [$y = 0$:], [$u = v = 0$], [(both the tangential and the normal velocity components must vanish at the wall)],
  [$y = infinity$:], [$u = U_(infinity)(x,t)$], [(the tangential velocity component must be identical to that computed from potential-flow theory at large distances from the wall)],
)
Those readers who are interested in the derivation of these equations from the complete Navier-Stokes equations for general fluid flow may consult Schlichting @boundary-layer-theory.

The Blasius problem assumes a steady flow, so all derivatives with respect to time will vanish.
Furthermore, the potential flow cannot detect the existence of a thin, flat plate held parallel to it; $U_(infinity)$ just remains constant at the free-stream value far from the plate, and hence $dif p/dif x$ is zero (there is no pressure gradient along the plate), as may be determined from Bernoulli's equation.
The boundary-layer equations are
// === page 62 ===
then seen to reduce to
$ u (partial u)/(partial x) + v (partial u)/(partial y) = nu (partial^2 u)/(partial y^2) $ <eq:blasius-momentum>
$ (partial u)/(partial x) + (partial v)/(partial y) = 0 $ <eq:blasius-continuity>
and the boundary conditions become 
#grid(
  columns: (auto, auto, auto),
  column-gutter: 1em,
  row-gutter: 0.65em,
  [$y = 0$:], [$u = v = 0$], [],
  [$y = infinity$:], [$u = U_(infinity)$], [(note that $U_(infinity)$ is now independent of x and t)]
)

To solve these equations Blasius introduced a new dimensionless variable $eta = y/delta$, or, using the expression for the approximate boundary-layer thickness from @eq:boundary-layer-thickness,
$ eta = y sqrt(U_(infinity)/(nu x)) $ <eq:blasius-similarity-variable>
A dimensionless _streamfunction_ $f(eta)$ was also introduced, such that
$ f(eta) = psi/sqrt(nu x U_(infinity)) $ <eq:blasius-streamfunction>
where $psi(x, y)$ is the streamfunction that had been well known to potential-flow theorists of the 19th Century; it is related to the flow velocities $u$ and $v$ in such a manner that it identically satisfies @eq:boundary-layer-continuity:
#set math.equation(numbering: _ => "(44a)")
$ u = (partial psi)/(partial y) $
#set math.equation(numbering: _ => "(44b)")
$ v = -(partial psi)/(partial x) $
#counter(math.equation).update(44)
from which we see that
// === page 63 ===
#set math.equation(numbering: none)
$ (partial u)/(partial x) = (partial^2 psi)/(partial y partial x) $
$ (partial v)/(partial y) = -(partial^2 psi)/(partial x partial y) = -(partial^2 psi)/(partial y partial x) $
$ (partial u)/(partial x) + (partial v)/(partial y) = (partial^2 psi)/(partial y partial x) - (partial^2 psi)/(partial y partial x) equiv 0 $
Using Equations #ref(<eq:blasius-similarity-variable>, supplement:none) and #ref(<eq:blasius-streamfunction>, supplement: none) to substitute into the expressions for the velocity components, Blasius obtained
#set math.equation(numbering: "(1)")
$ u = (partial psi)/(partial y) = (partial psi)/(partial eta) (partial eta)/(partial y) = U_(infinity) (dif f(eta))/(dif eta) = U_(infinity) f'(eta) $ <eq:blasius-u-velocity>
$ v = -(partial psi)/(partial x) = 1/2 sqrt((nu U_(infinity))/x) (eta f' - f) $ <eq:blasius-v-velocity>
The prime symbol ($'$) is often used in calculus to denote a derivative; hence $(dif f(eta))/(dif eta)$ is also written $f'(eta)$, or simply $f'$.
Higher-order derivatives are denoted by multiple primes; hence $(dif^2 f(eta))/(dif eta^2)$ is equivalent to $f''$ , etc.

From Equations #ref(<eq:blasius-u-velocity>, supplement:none) and #ref(<eq:blasius-v-velocity>, supplement: none) it is possible to obtain expressions for the velocity derivatives of @eq:blasius-momentum in terms of the nondimensional vertical coordinate $eta$ and the nondimensional streamfunction $f$ :
$ (partial u)/(partial x) = (partial u)/(partial eta) (partial eta)/(partial x) = [U_(infinity) f''] [ -(eta)/(2x) ] $
$ (partial u)/(partial y) = (partial u)/(partial eta) (partial eta)/(partial y) = [U_(infinity) f''] sqrt(U_(infinity)/(nu x)) $ <eq:blasius-du-dy>
$ (partial^2 u)/(partial y^2) = U_(infinity) sqrt(U_(infinity)/(nu x)) (partial f'')/(partial eta) (partial eta)/(partial y) = (U_(infinity)^2)/(nu x) f''' $ <eq:blasius-second-derivative>
Substituting #ref(<eq:blasius-u-velocity>, supplement: none) through #ref(<eq:blasius-second-derivative>, supplement: none) into @eq:blasius-momentum, we have
$ -(U_(infinity)^2)/(2x) eta f'f'' + (U_(infinity)^2)/(2x)(eta f' - f)f'' = nu (U_(infinity)^2)/(x nu) f''' $
which can be algebraically simplified to
// === page 64 ===
$ f f'' + 2 f''' = 0 $ <eq:blasius-ode>
with the boundary conditions
$ eta = 0 : f = 0 ; f' = 0 $
$ eta = infinity : f' = 1 $ 

Now the advantage Blasius obtained by introducing the dimensionless vertical coordinate and dimensionless stream-function was that he was able to reduce Equations #ref(<eq:blasius-momentum>, supplement: none) and #ref(<eq:blasius-continuity>, supplement: none), a nonlinear system of two partial differential equations, to @eq:blasius-ode which is known as an _ordinary_, _homogeneous_, _nonlinear_ differential equation: "ordinary" because $f$ is a function of the single variable $eta$, "homogeneous" because the right side is zero, and "nonlinear" because the product of $f$ with $f''$ appears in the equation.
Such an equation is easier to solve than the original system of equations; "easier", however, does not mean "easy", and a solution to equation @eq:blasius-ode has never been obtained in closed form.
Power series methods have been used to obtain accurate solutions by numerical means, but the procedure is rather complex and its mechanics are of little interest to model rocketeers (readers desiring a presentation of the method are urged to consult Reference @boundary-layer-theory).
@fig:laminar-boundary-numerical-solution presents the numerical tabulation obtained by L. Howarth from his highly accurate solution of @eq:blasius-ode.

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    // columns: (auto, auto, auto, auto),
    stroke: none,
    align: center,
    inset: (x: 8pt, y: 3pt),
    table.hline(),
    table.header(
      table.cell(inset: (y: 10pt))[$eta = y sqrt(U_infinity / (nu x))$],
      table.cell(inset: (y: 10pt))[$f$],
      table.cell(inset: (y: 10pt))[$f' = u \/ U_infinity$],
      table.cell(inset: (y: 10pt))[$f''$],
    ),
    table.hline(stroke: 0.5pt),
    [0.0], [0.00000], [0.00000], [0.33206],
    [0.2], [0.00664], [0.06641], [0.33199],
    [0.4], [0.02656], [0.13277], [0.33147],
    [0.6], [0.05974], [0.19894], [0.33008],
    [0.8], [0.10611], [0.26471], [0.32739],
    [1.0], [0.16557], [0.32979], [0.32301],
    table.cell(colspan: 4, inset: (top: 0pt, bottom: 6pt))[],
    [1.2], [0.23795], [0.39378], [0.31659],
    [1.4], [0.32298], [0.45627], [0.30787],
    [1.6], [0.42032], [0.51676], [0.29667],
    [1.8], [0.52952], [0.57477], [0.28293],
    [2.0], [0.65003], [0.62977], [0.26675],
    table.cell(colspan: 4, inset: (top: 0pt, bottom: 6pt))[],
    [2.2], [0.78120], [0.68132], [0.24835],
    [2.4], [0.92230], [0.72899], [0.22809],
    [2.6], [1.07252], [0.77246], [0.20646],
    [2.8], [1.23099], [0.81152], [0.18401],
    [3.0], [1.39682], [0.84605], [0.16136],
    table.cell(colspan: 4, inset: (top: 0pt, bottom: 6pt))[],
    [3.2], [1.56911], [0.87609], [0.13913],
    [3.4], [1.74696], [0.90177], [0.11788],
    [3.6], [1.92954], [0.92333], [0.09809],
    [3.8], [2.11605], [0.94112], [0.08013],
    [4.0], [2.30576], [0.95552], [0.06424],
    table.cell(colspan: 4, inset: (top: 0pt, bottom: 6pt))[],
    [4.2], [2.49806], [0.96696], [0.05052],
    [4.4], [2.69238], [0.97587], [0.03897],
    [4.6], [2.88826], [0.98269], [0.02948],
    [4.8], [3.08534], [0.98779], [0.02187],
    [5.0], [3.28329], [0.99155], [0.01591],
    table.cell(colspan: 4, inset: (top: 0pt, bottom: 6pt))[],
    [5.2], [3.48189], [0.99425], [0.01134],
    [5.4], [3.68094], [0.99616], [0.00793],
    [5.6], [3.88031], [0.99748], [0.00543],
    [5.8], [4.07990], [0.99838], [0.00365],
    [6.0], [4.27964], [0.99898], [0.00240],
    table.cell(colspan: 4, inset: (top: 0pt, bottom: 6pt))[],
    [6.2], [4.47948], [0.99937], [0.00155],
    [6.4], [4.67938], [0.99961], [0.00098],
    [6.6], [4.87931], [0.99977], [0.00061],
    [6.8], [5.07928], [0.99987], [0.00037],
    [7.0], [5.27926], [0.99992], [0.00022],
    table.cell(colspan: 4, inset: (top: 0pt, bottom: 6pt))[],
    [7.2], [5.47925], [0.99996], [0.00013],
    [7.4], [5.67924], [0.99998], [0.00007],
    [7.6], [5.87924], [0.99999], [0.00004],
    [7.8], [6.07923], [1.00000], [0.00002],
    [8.0], [6.27923], [1.00000], [0.00001],
    table.cell(colspan: 4, inset: (top: 0pt, bottom: 6pt))[],
    [8.2], [6.47923], [1.00000], [0.00001],
    [8.4], [6.67923], [1.00000], [0.00000],
    [8.6], [6.87923], [1.00000], [0.00000],
    [8.8], [7.07923], [1.00000], [0.00000],
    table.hline()
  ),
  caption: "Numerical solution of the laminar boundary layer over a flat plate at zero angle of attack, obtained after the method of H. Blasius and L. Howarth."
) <fig:laminar-boundary-numerical-solution>

These data can be used to obtain a picture of the velocity distribution in the boundary layer; the results for the horizontal velocity component are plotted in @fig:blasius-velocity-profile.
Near the wall
// === page 65 ===
// Table 1
// === page 66 ===
// Table 1 (continued)
// === page 67 ===
// Figure 14
// === page 68 ===
the horizontal velocity component is nearly a linear function of the $y$ coordinate, but as $y$ increases the slope of the curve rapidly steepens as $u$ approaches the potential-flow velocity $U_(infinity)$.

#figure(
  image("../../assets/figures-original/fig3-14.png"),
  caption: [Horizontal velocity component vs. $eta$ in a laminar boundary layer over a flat plate at zero angle of attack.
  $eta$ has been taken as the vertical axis because it is the dimensionless coordinate perpendicular to the plate's surface.
  The quantity $delta^*$ is called the _displacement thickness_ and is equal to approximately $1/3 delta$.]
) <fig:blasius-velocity-profile>

Notice that the free-stream velocity is attained _asymptotically_; i.e., that the boundary layer shades gradually into the exterior flow, so that the concept of "boundary-layer thickness" is ambiguous.
The generally-accepted definition is based on the distance from the wall where the velocity differs by 1% from $U_(infinity)$; i.e., where $u = 0.99 U_(infinity)$.
From @fig:laminar-boundary-numerical-solution we see that this corresponds to $eta approx 5.0$; hence
$ delta = 5 sqrt((nu x)/U_(infinity)) $ <eq:54>
Evaluating this expression for $U_(infinity)$ = #qty(60, "m/s") (#qty("6000", "cm/s")) and $nu$ = #qty("1.495e-5", "m^2/s") (#qty("0.1495", "cm^2/s")), we obtain
#set math.equation(numbering: _ => "(55a)")
$ delta = num(3.10e-3) sqrt(x) $
for x and $delta$ in meters, and
#set math.equation(numbering: _ => "(55b)")
$ delta = num(3.10e-2) sqrt(x) $
#set math.equation(numbering: "(1)")
#counter(math.equation).update(55)
for x and $delta$ in centimeters.
At $x$ = #qty("1", "cm"), then, the boundary-layer thickness $delta$ is #qty("0.031", "cm"); at $x$ = #qty("10", "cm") $delta$ is #qty("0.098", "cm"), while at $x$ = #qty("100", "cm") (#qty("1", "m") $delta$ is #qty("0.310", "cm").
The corresponding Reynolds numbers based on $x$ are #num(4.02e4), #num(4.02e5), and #num(4.02e6), respectively.

The transverse component of velocity, $v$, can also be
// === page 69 ===
determined from the Blasius solution by substituting values for $f$ and $f'$ at each value of $eta$ desired into @eq:blasius-v-velocity.
The variation of the nondimensional quantity $v/U_infinity sqrt((U_infinity x)/nu)$ with $eta$ is plotted in @fig:transverse-velocity.
As $eta$ approaches infinity $v$ does not vanish, but instead attains the asymptotic value
$ v_(infinity) = 0.865 U_(infinity) sqrt(nu/(x U_(infinity))) $
Examining again the case of $U_(infinity)$ = #qty("60", "m/s"), we obtain
$ v_infinity = (3.22 times 10^(-2))/sqrt(x) "m/s" $
where $x$ must be given in meters.
Thus, at a point #qty("1", "cm") from the plate leading edge (that is, #qty("0.01", "m")), the value of $v_(infinity)$ is #qty("0.322", "m/s")--insignificant, of course, compared with $U_(infinity)$ but still nonzero.
The nonzero value of the transverse velocity at the upper edge of the boundary layer is explained by the fact that the increasing boundary-layer thickness causes the airstream to be displaced from the wall as it flows along it, creating a slight outward velocity component.
This is _not_ the same as the flow _separating_ entirely from the wall, a phenomenon that occurs only in an "adverse pressure gradient"; i.e., when the pressure in the boundary layer is increasing in the direction of flow.
The flat plate at zero angle of attack, it will be recalled, exhibits a _zero_ pressure gradient.

#figure(
  image("../../assets/figures-original/fig3-15.png"),
  caption: [Nondimensionalized transverse velocity component $v/U_(infinity) sqrt((U_(infinity) x)/nu)$ vs. $eta$ in a laminar boundary layer over a flat plate at zero angle of attack.
  Again, $eta$ has been taken as the vertical axis.]
) <fig:transverse-velocity>

The Blasius solution enables us to determine the skin-friction drag on the flat plate with a laminar boundary layer by specializing the equation for the viscous drag on a surface in general, two-dimensional flow:
// === page 70 ===
// Figure 15
// Figure 16
#figure(
  image("../../assets/figures-original/fig3-16.png"),
  caption: [Notation used in determining the friction drag of an object of finite thickness in laminar flow.]
) <fig:friction-drag-notation>

// === page 71 ===
$ D_v = b integral_(s=0)^ell tau_0 cos phi dif s $ <eq:skin-friction-drag-integral>
where $tau_0$ is the shearing stress at the wall, $b$ is the span of the object (dimension transverse to the flow), and $ell$ is distance measured around the object's profile from front to rear.
The notation of @eq:skin-friction-drag-integral is explained pictorially in @fig:friction-drag-notation.
For a flat plate of negligible thickness the angle $phi$ is zero everywhere, so $cos phi = 1.0$.
In such a case the differential path length $dif s$ is also equal to $dif x$, so
$ D_v = b integral_(x=0)^ell tau_0 dif x $ <eq:59>
From Equations #ref(<eq:wall-shear-stress>, supplement: none) and #ref(<eq:blasius-du-dy>, supplement: none)
$ tau_0(x) = mu ( (partial u)/(partial y) )_(y=0) = mu U_infinity sqrt((U_infinity)/(nu x)) dot.op f''(0) = alpha U_infinity sqrt((U_infinity)/(nu x)) $ <eq:60>
where the quantity $f''(0)$ has been represented by the symbol $alpha$ (not to be confused with angle of attack in this application).
From @fig:laminar-boundary-numerical-solution, $alpha$ is found to be #num(0.332).
Hence, the skin-friction drag on one side of the plate is
$ D_v = .332 mu b U_infinity sqrt((U_infinity)/nu) integral_(x=0)^l (dif x)/sqrt(x) = .664 b U_infinity sqrt(mu rho ell U_infinity) $
For both sides (the total friction drag), we have
$ 2D_v = 1.328 b sqrt(U_infinity^3 mu rho l) $
The friction drag coefficient for laminar flow over a flat plate wetted on both sides is thus
$ C_f = (2 D_v)/(1/2 rho U_infinity^2 A) = (1.328)/sqrt(R_ell) $ <eq:63>
where $A$, the lateral area of both sides of the plate, is $2 b ell$
// === page 72 ===
and $R_ell$ is the Reynolds number based on the length of the plate _if_ the plate is too short for transition to turbulent flow to occur anywhere on its surface.
If the plate is sufficiently long for transition to occur, $R_ell$ is the Reynolds number based on the distance from the leading edge to the transition zone and the coefficient computed according to @eq:63 is valid only for that portion of the plate forward of the transition region.
Recalling our numerical example of $U_infinity$ = #qty("60", "m/s") suppose we compute the friction drag coefficient of a typical model rocket fin with an average chord of #qty("3", "cm") (#qty("0.03", "m")).
For such a case we obtain
$ C_f = (1.328)/sqrt(12.06 times 10^4) = .00382 $
We must remember, however, that friction drag coefficients as originally computed are based on wetted area--that is, total lateral surface area.
To use them in calculating the overall drag coefficient of a model rocket, one must convert them to coefficients based on maximum body frontal area.
This procedure will be described later on.

=== The Turbulent Boundary Layer on a Smooth, Flat Plate <sec:turbulent-boundary-layer>
At a certain value of the Reynolds number, the fluid flow in the boundary layer above a given surface will change from laminar to turbulent--a phenomenon known as _transition_.
@plate:reynolds-experiment illustrates a case of transition occurring in a channel of water.
As the Reynolds number increases from _subcritical_ (fully laminar flow) to _supercritical_ (fully turbulent flow) values, a thread of dye injected into the fluid is subjected
// === page 73 ===
// Plate 3
// === page 74 ===
to increasing mixing action until finally the entire channel is colored.
In this section we will consider the structure of the fully-turbulent boundary layer in the flow over a smooth, flat plate, noting how the velocity profiles, boundary-layer thickness, and skin-friction drag differ from the laminar case.

#figure(
  image("../../assets/figures-original/plate3-3.png"),
  kind: "plate",
  supplement: [Plate],
  caption: [The Reynolds dye experiment, illustrating the transition from laminar to turbulent flow in a channel of liquid.
  A thread of dye injected into the flowing fluid at first remains smooth and straight (a), but farther down the channel the critical Reynolds number of the flow has been exceeded and the stream is turbulent (b), causing the dye to be mixed.]
) <plate:reynolds-experiment>

In laminar flow, streamlines move more or less parallel to each other with negligible mixing, and if the flow is steady the velocity at any point in the flow remains constant as time goes on.
When turbulent flow is observed closely, however, subsidiary motions of the fluid _transverse_ to the main motion downstream are detected @boundary-layer-theory.
The velocity at a point is no longer constant, but is subject to _excursions_, or variations, about some average value.
This behavior amounts to mixing between the streamlines and causes an exchange of momentum in the transverse direction, because each fluid element essentially retains its forward momentum while mixing is occurring.
Hence, the velocity profile in the turbulent boundary layer is such that the x-component of velocity increases far more slowly with height over most of the boundary-layer thickness than is the case for the laminar boundary layer.
// reviewed up to here

The distinctive feature of turbulent flow is the irregular, high-frequency oscillations exhibited by the velocity and pressure at a point.
These quantities can be considered constants only as an average over an extended period of time.
Turbulent flow must still observe the no-slip condition at the wall, however, and there is thus a region very close to the wall where viscous stresses are of larger magnitude than the stresses due to
// === page 75 ===
turbulence which dominate the rest of the boundary layer.
Since the conditions of flow in this very thin region--perhaps 1% or so of the total turbulent boundary layer thickness--are essentially laminar, it is known as the _laminar sublayer_.
Despite its small thickness, the sublayer plays a vital role in determining the magnitude of the viscous shearing stress at the wall and hence the turbulent skin-friction drag.
We shall encounter it again in @sec:roughness-drag when we examine drag due to surface roughness.

Because of its extensive applicability, we would like to determine the turbulent skin-friction drag on a smooth, flat plate as we did in the laminar-flow case.
The same general methods of derivation cannot, however, be used again owing to two major difficulties: (a) very little is known about the nature of the transition that occurs as one passes upward from the laminar sublayer to the turbulent region; and (b) the laws of friction which are effective in the sublayer are also unknown.
We proceed, then, on a different tack, by assuming that the boundary-layer velocity distribution over a plate is similar to that within a circular pipe.
This allows us to avail ourselves of the extensive data available for pipe flow, which has been studied in experiments preferentially to the plate case since it is much more difficult to carry out measurements in the boundary layer of a plate than in that within a pipe @boundary-layer-theory.

The validity of this assumption has been established, at least for moderate Reynolds numbers, by experimental investigations.
Since the boundary layer in a pipe is formed under
// === page 76 ===
the influence of a pressure gradient (the pressure at the downstream end of the pipe must be less than that at the upstream end, or no fluid would flow through it), while for the flat plate $(dif p)/(dif x)$ was assumed equal to zero, the velocity distributions for the two configurations certainly cannot be exactly identical.
Because the friction drag is calculated from a _spatial integral_ of the fluid momentum in cases of turbulent flow, however, small differences in the velocity distribution are not critical @boundary-layer-theory.

In order to compute skin-friction drag for a turbulent boundary layer, it is first necessary to introduce the concept of _the momentum thickness_, $theta$, of the boundary layer.
The rate at which x-momentum per unit span of the plate (or per unit circumferential distance of the pipe) is being lost due to the presence of the boundary layer instead of potential flow is given by $rho integral_0^infinity u (U_infinity - u) dif y$.
We may therefore define a quantity $theta$ such that
$ rho U_infinity^2 theta = rho integral_(y=0)^infinity u (U_infinity -u) dif y $ <eq:momentum-thickness-def>
or
$ theta = integral_(y=0)^(infinity) u/U_(infinity) (1 - u/U_(infinity)) dif y $ <eq:momentum-thickness-integral>
Then in the case of laminar flow, since $(u/U_infinity) = f'$,
$ theta = sqrt((nu x)/U_(infinity)) integral_(eta=0)^infinity f'(1-f') dif eta $
or
$ theta = 0.664 sqrt((nu x)/U_(infinity)) $
// === page 77 ===
This is approximately $1/8$ of the boundary-layer thickness defined by @eq:boundary-layer-thickness.

Now we may relate $theta$ to the skin-friction drag in the following manner: consider a flat plate surrounded by a rectangular _control surface_ (an imaginary surface in space--a concept often used in the analysis of fluid-flow problems) identified by its corner points, $A A_1 B_1 B$, as in @fig:turbulent-control-surface.
Segment $A_1 B_1$, parallel to the plate, is sufficiently far from the wall that it lies in the region of undisturbed velocity $U_infinity$.
Pressure forces in such a case are constant over the whole control surface, so one need not consider their contribution to the fluid momentum.
Due to symmetry, moreover, segment AB contributes nothing to the momentum in the x-direction.
Assigning positive value to mass flowing in and negative value to mass flowing out of the region enclosed by the control surface, the momentum balance may be expressed as in @fig:flow-momentum-accounting.

#figure(
  table(
    align: horizon,
    columns: (1fr, 1fr, 1fr),
    table.header(
      [Cross-Section], [Rate of Flow], [Momentum Flux in x-Direction]
    ),
    [$upright(A B)$], [0], [0],
    [$upright(A A_1)$], [$b integral_0^h U_infinity dif y$], [$rho b integral_0^h U_infinity^2 dif y$],
    [$upright(B B_1)$], [$-b integral_0^h u dif y$], [$-rho b integral_0^h u^2 dif y$],
    [$upright(A_1 B_1)$], [$-b integral_0^h (U_infinity - u) dif y$], [$- rho b integral_0^h U_infinity (U_infinity - u) dif y$],
    [sum = control surface], [total net rate of flow = 0], [total momentum flux = drag]
  ),
  caption: [Volume flow and momentum flux accounting associated with the control surface pictured in @fig:turbulent-control-surface, for use in calculating turbulent skin-friction drag.]
) <fig:flow-momentum-accounting>

#figure(
  image("../../assets/figures-original/fig3-17.png"),
  caption: [Control surface for calculating the friction drag due to a turbulent boundary layer over a flat plate at zero angle of attack.]
) <fig:turbulent-control-surface>

Momentum conservation requires that the drag force $D$ be exactly equal to the total momentum flux through the control surface, or
$ D = rho b integral_0^h (U_infinity^2 - u^2 - U_infinity^2 - u U_infinity) dif y $
The upper limit of integration may be changed to infinity, as the integrand is zero for $y > h$; hence
$ D = rho b integral_0^infinity u (U_infinity - u) dif y $ <eq:momentum-deficit-drag-one-side>
This expression applies to a plate wetted on only one side; to obtain the drag for a plate wetted on both sides, we evaluate
// === page 78 ===
// Table 2
// === page 79 ===
// Figure 17
// === page 80 ===
$ 2D = rho b integral_(-infinity)^infinity u (U_infinity - u) dif y $ <eq:momentum-deficit-drag>

Two remarks concerning these integrals should be made here.
First, @eq:momentum-deficit-drag is applicable to any symmetrical cylindrical body, not only a flat plate; in the case of a cylindrical body $b$ is merely replaced by the circumference of the cylinder.
Second, the integral may be evaluated at any station $x$ on the body, in which case it will give the drag due to skin friction on the region extending from the leading edge to that particular station.

Now from @eq:momentum-thickness-def it will be recalled that
$ U_(infinity)^2 theta = integral_(y=0)^(infinity) u (U_(infinity) - u) dif y $ This expression is identical to the integral appearing in Equations #ref(<eq:momentum-deficit-drag>, supplement: none) and #ref(<eq:momentum-deficit-drag-one-side>, supplement: none); hence we have
$ D = b rho U_(infinity)^2 theta $ <eq:drag-momentum-thickness>

We return now to an explicit consideration of the turbulent boundary layer on a flat plate.
From the empirical results for turbulent boundary layers in pipe flow we adopt the "1/7th-power velocity distribution law" in the form
$ u/U_(infinity) = (y/delta)^(1/7) $ <eq:turbulent-velocity-profile>
As in the laminar case, this relationship requires that all the velocity profiles along a flat plate in turbulent flow be of the same form, and thus one curve plotted in dimensionless coordinates can represent them all.

The results of experiments with turbulent boundary layers
// === page 81 ===
in circular pipes have also shown that the shearing stress at the wall obeys the relation
$ (tau_0)/(rho U_(infinity)^2) = 0.0225 (nu/(U_(infinity) delta))^(1/4) $ <eq:turbulent-wall-shear>
The momentum thickness can now be obtained in terms of the boundary-layer thickness $delta$ by direct integration from Equations #ref(<eq:momentum-thickness-integral>, supplement: none) and #ref(<eq:turbulent-velocity-profile>, supplement: none):
#{ set math.equation(numbering: none)
$ Theta &= integral_(y=0)^delta u/U_infinity (1 - u/U_infinity) dif y \
        &= integral_(y=0)^delta (y/delta)^(1/7) [1 - (y/delta)^(1/7)] dif y \
        &= integral_0^delta (y/delta)^(1/7) dif y - integral_0^delta (y/delta)^(2/7) dif y = 7/8 delta - 7/9 delta $
}
Then
$ theta = 7/72 delta $ <eq:momentum-thickness-turbulent>
Now if we differentiate @eq:drag-momentum-thickness with respect to $x$ we obtain
$ 1/b (dif D)/(dif x) = tau_0(x) = rho U_(infinity)^2 (dif theta)/(dif x) $ <eq:drag-derivative>
Combining Equations #ref(<eq:momentum-thickness-turbulent>, supplement: none) and #ref(<eq:drag-derivative>, supplement: none) then yields
$ (tau_0)/(rho U_(infinity)^2) = (d Theta)/(dif x) = 7/72 (dif delta)/(dif x) $ <eq:combined-momentum-shear>
Substituting #ref(<eq:combined-momentum-shear>, supplement: none) into #ref(<eq:turbulent-wall-shear>, supplement: none), we have
$ 7/72 (dif delta)/(dif x) = 0.0225 (nu / (U_(infinity) delta))^(1/4) $
An explicit expression for $delta$ as a function of $x$ can now be obtained by integrating this ordinary differential equation in $delta$, assuming that $delta = 0$ at $x = 0$.
The result is
// === page 82 ===
$ delta = 0.37 x ( (U_(infinity) x)/nu )^(-1/5) $
and
$ theta = 0.036 x ((U_(infinity) x) / nu)^(-1/5) $ <eq:turbulent-momentum-thickness>

The boundary-layer thickness in turbulent flow is thus seen to increase more rapidly with distance than in the laminar case: $delta(x)$ is proportional to $x^(4/5)$ for a turbulent boundary layer, while $delta(x)$ for a laminar boundary layer varies as $x^(1/2)$.
The difference is due to the mixing action present in turbulent flow, which causes greater momentum and energy losses per unit time than is the case for laminar boundary layers.

From Equations #ref(<eq:drag-momentum-thickness>, supplement: none) and #ref(<eq:turbulent-momentum-thickness>, supplement: none), the turbulent skin-friction drag on one side of a flat plate may now be written as
$ D = b rho U_(infinity)^2 theta = 0.036 rho U_(infinity)^2 b ell ((U_(infinity) ell)/nu)^(-1/5) $ <eq:turbulent-friction-drag>
The drag varies as $U_(infinity)^(4/5)$ and $ell^(4/5)$, as compared to $U_(infinity)^(3/2)$ and $ell^(1/2)$ for the laminar boundary layer.
The skin-friction coefficient $C_f$ can then be determined from its definition and @eq:turbulent-friction-drag:
$ C_f = D/(1/2 rho U_(infinity)^2 b ell) $
$ C_f = (2 theta(ell))/(ell) $
and finally, we arrive at the result
$ C_f = 0.072 ((U_(infinity) ell)/nu)^(-1/5) $
This expression has been found to represent experimental results very well, provided the value of the numerical coefficient is altered slightly to 0.074 @boundary-layer-theory:
// === page 83 ===
$ C_f = 0.074 ((U_(infinity) ell)/nu)^(-1/5) = 0.074 (R_ell)^(-1/5) $ <eq:86>

This relationship, valid for a flat plate with a completely turbulent boundary layer from the leading edge downstream, is limited to the range of Reynolds numbers between #num("5e5") and #num("1e7")--a range which, fortunately, includes the upper limit of $R$ to be expected in the vast majority of model rocket flights.

Table 3 summarizes the results of our analyses of purely laminar and purely turbulent boundary layers:
#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    align: horizon,
    stroke: none,
    row-gutter: 5pt,
    inset: 10pt,
    table.hline(),
    table.header(
      [characteristic], [laminar value], [turbulent value]
    ),
    table.hline(stroke: 0.5pt),
    [$C_f$], [$1.328/(R_ell)^(1/2)$], [$0.074/(R_ell)^(1/5)$],
    [$delta$], [$5 sqrt((nu x)/U_infinity)$], [$0.37 x ((U_infinity x)/nu)^(-1/5)$],
    [$u/U_infinity$], [as given in @fig:laminar-boundary-numerical-solution], [$(y/delta)^(1/7)$],
    table.hline(),
  )
)
To give a representative example of a turbulent skin-friction coefficient, suppose we consider again the free-stream velocity $U_(infinity)$ = #qty("60", "m/s") and a plate with a length of #qty("0.3", "m"), giving a Reynolds number of #num("1.206e6").
Assuming that some condition of free-stream turbulence or some device like a trip-wire has caused the boundary layer to be turbulent all along the length of the plate, we derive the result
#{ set math.equation(numbering: none); $ C_f = .0045 $ }

// === page 84 ===
=== Boundary Layer Transition <sec:bl-transition> 
==== Effect of Pressure Gradient and Reynolds Number <sec:pressure-gradient-re>
The two preceding sections dealt with boundary layers that are entirely laminar or entirely turbulent in character.
In reality, the flow over a flat plate may exhibit both forms of behavior.
Laminar conditions will generally exist from the leading edge downstream to a point at which the local Reynolds number $R_x = U_(infinity) x / nu$ attains a value somewhere between #num("3e5") and #num("3e6").
At higher local Reynolds numbers the flow is almost certain to be turbulent.

The exact value of the Reynolds number at which this phenomenon of _transition_ from laminar to turbulent flow occurs depends on a number of factors: the turbulence level of the free stream, the roughness of the surface, centrifugal body forces due to rotation of the body, and whether or not heat is being transferred to the boundary layer from the body or from external sources.
The pressure gradient in the external flow (which is uniformly zero for a flat plate) also exerts a considerable influence on transition, as will be seen shortly.

The hypothesis which underlies theoretical studies of transition was first enunciated by Osborne Reynolds: that the process of transition from laminar to turbulent flow comes about as the consequence of an _instability_ in the laminar flow @boundary-layer-theory.
Small disturbances, which may arise from any of the sources listed above, are assumed to act upon the laminar flow.
The theory of stability attempts to determine whether these disturbances magnify or die away with time.
If they decay, the flow is considered stable; if, instead, they grow in magnitude, the
// === page 85 ===
flow is regarded as unstable and transition to a turbulent pattern _may_ result.
The ultimate object of the stability theory is a prediction of the critical Reynolds number, $R_("crit")$, for which transition may be expected.

The results of the stability analysis for a flat plate will not be presented here (readers interested in this analysis may consult Reference @boundary-layer-theory), as they are not directly applicable to the three-dimensional boundary layer on a model rocket.
Instead, we shall investigate briefly the effects of the pressure gradient in the external flow on boundary-layer stability, and then present the hypothetical model of transition on model rockets which will be used for the calculation of drag coefficients in @sec:zero-lift-drag-calc.

The great English scientist, Lord Rayleigh (1842-1919) was the first to propose that velocity profiles with a _point of inflection_ (point at which the curvature reverses) are unstable.
@fig:inflection-profiles compares such a profile with one found in a region of stable flow.
Rayleigh's observation is of great practical significance, because there is a direct relationship between the existence of an inflection point and the nature of the local pressure gradient.
The pressure distribution on a surface in fluid flow (for cases in which there is no separation of the boundary layer) is determined by the theory of potential flow, which, it will be remembered, applies to the inviscid, "perfect" fluid.
In real cases it is found that this theoretical pressure distribution agrees very closely with measured pressure distributions, as if the boundary layer were not present.
In a sense, then, the external flow _impresses_ its pressure distribution
// === page 86 ===
// Figure 18
// === page 87 ===
on the boundary layer.
Along a surface with a _favorable_ pressure gradient; that is, with the pressure _decreasing_ in the downstream direction, the boundary-layer velocity profiles will be full and without inflection points, as in @fig:inflection-profiles (b).
In the presence of an _adverse_ pressure gradient; i.e., where the pressure _increases_ downstream, the velocity profiles will generally develop inflection points, as in @fig:inflection-profiles (a).
In summary, then, a _favorable_ pressure gradient tends to _stabilize_ the flow in the boundary layer, while an _adverse_ pressure gradient tends to _destabilize_ it.
The point of minimum pressure on a body is therefore of considerable importance; it determines the point of transition, and the two are generally in close proximity.

#figure(
  image("../../assets/figures-original/fig3-18.png"),
  caption: [Diagram (a) shows a boundary layer velocity profile u(y) versus height y.
  Profile (a) has a point of inflection; that is, a point at which the curvature of the velocity profile reverses.
  Profile (b) is fully convex in the direction of flow.
  The flow of profile (a) is unstable, while that of (b) is stable.]
) <fig:inflection-profiles>

For an object such as a circular cylinder held with its axis perpendicular to the stream, the region of minimum pressure occurs near the shoulder as seen in @fig:cylinder-pressure (the angles $phi = 0 degree$ and $180 degree$ correspond to the front and rear stagnation points, respectively).
This experimental fact could also be _deduced_ from @eq:total-pressure-stagnation: since the flow must be accelerated initially to pass over the upstream half of the cylinder, there is a corresponding decrease in static pressure in this region.
Along the downstream side (in the ideal case) the flow is decelerated to its original undisturbed velocity and static pressure.

Something analogous to this process occurs on the nose of a model rocket: the flow is accelerated slightly and a point of minimum pressure is attained somewhere in the vicinity of the body-to-nosecone joint.
If the rocket possesses a circular
// === page 88 ===
cylindrical body, no further deflection of the flow will occur until the vicinity of the base is reached.
Along the body, then, it is expected that the pressure gradient is either zero or very small; hence no adverse pressure gradient is expected anywhere along the airframe of such a rocket and it is assumed that the location of the transition point on a typical model rocket is independent of the external pressure distribution.
If the model has a boattail, however, an adverse pressure gradient will exist on it and transition--or even separation--can be expected in the flow about such a component.

No data are available to indicate either where transition first occurs on a model rocket or the corresponding critical Reynolds number.
The following hypothetical description, based on the flow behavior observed about streamlined bodies similar to model rockets, is advanced with some reservations as a model for boundary-layer transition on model rockets: at low velocities, corresponding to Reynolds numbers based on body length below about #num("3e5"), the boundary layer on a model rocket will be completely laminar.
As the velocity increases, the local Reynolds number $R_x = U_(infinity) x / nu$ (based on axial distance from the nosecone tip) will exceed at some station $x$ the experimentally-determined (or assumed) value of $R_("crit")$ for the rocket.
This event will first occur near the model's tail, where the local Reynolds numbers are greatest; hence a small region of turbulent flow will first appear on the body near the base.
As the velocity continues to increase, all values of $R_x$ also increase and the transition point, determined by $R_x = R_("crit")$, will move progressively toward the nose.

// === page 89 ===
A similar progression of events will occur on the fins, but at much higher body Reynolds numbers $R_ell$, because the nature of the flow over the fins is determined by the Reynolds number based on fin chord length $R_c = U_(infinity) c / nu$.
For typical model rockets, $R_ell$ is an order of magnitude greater than $R_c$; a turbulent boundary layer will therefore not generally be found on model rocket fins except in cases of exceptionally large rockets and/or exceptionally high velocities.
The reasoning of this and the last paragraph is based on the assumption of perfectly smooth surfaces.
Roughness, as will be shown in the following section, can induce premature transition.

==== Effects of Surface Roughness <sec:surface-roughness>
The presence of roughness elements, whether isolated or distributed in groups, in a laminar flow is known to be generally conducive to transition.
Under otherwise identical conditions, transition occurs at a lower Reynolds number on a rough wall than on a smooth one.
This behavior follows from the theory of stability, as the roughness elements create disturbances in the flow which add to those already present in the boundary layer and the external flow.
Transition will occur at a lower value of $R$ than would otherwise be the case if the disturbances created by the roughness exceed those due to the turbulence already present in the flow.
If, however, the roughness elements are very small, turbulent disturbances from the free stream will dominate and the roughness should have no effect on transition.

We examine first the effect of a cylindrical wire which is attached to a wall at right angles to the stream direction.
// === page 90 ===
S. Goldstein has determined the critical height $k_("crit")$ of such a wire; i.e., the wire diameter just small enough so as not to influence transition, to be
$ k_("crit") = (7 nu) / sqrt( tau_"ok" / rho) $
where $tau_("ok")$ is the shearing stress at the wall in the laminar boundary layer at the location of the wire.
Now for a flat plate, @eq:60 gives
$ tau_0(x) = mu U_infinity sqrt((U_infinity)/(nu x)) f''(0) $
and from @fig:laminar-boundary-numerical-solution, $f''(0) = 0.332$.
Recognizing that $mu = nu/rho$,
$ tau_0(x) = (0.332)/sqrt(R_x) rho U_infinity^2 = tau_("ok") $
Then for a flat plate,
$ k_("crit") = (12.2 nu (R_x)^(1/4))/(U_infinity) = 12.2 ( nu/(U_infinity) )^(3/4) x^(1/4) $ <eq:90>
where the quantities involved must all be members of the same consistent set of units.
For example, if $U_infinity$ = #qty("60", "m/s") and $x$ = #qty("3", "cm")
(#qty("0.03", "m")), the critical height will be

#align(center)[$k_("crit")$ = #qty("5.67e-5", "m") = #qty("5.67e-3", "cm")]

The cylindrical wire of the foregoing analysis could represent a paintbrush hair, the body-to-nosecone joint, or any similar small, cylindrical protuberance on the model's surface.
If such protuberances have heights greater than the value of $k_("crit")$ computed according to @eq:90, there is some danger of premature transition.
For the nosecone joint or surface, considering the stabilizing effect of the favorable pressure
// === page 91 ===
gradient, the value of $k_("crit")$ given by @eq:90 is probably somewhat too small.
Assuming it _does_ give the correct _order of magnitude_, however, it is apparent that a model rocket requires a rather smooth surface to minimize the possibility of transition occurring prematurely, with its consequent marked increase in skin-friction drag.

In reality, the transition point will occur somewhat downstream of a roughness element which just exceeds $k_("crit")$ as determined by @eq:90.
This is due to the fact that a finite "amplification time" is required for the disturbances due to the protrusion to generate turbulent flow.
In order to induce effectively instantaneous transition, the height of the protrusion must be two or three times that predicted by @eq:90.

Distributed roughness elements; i.e., particles typified by dust or sandpaper grit, can also induce premature transition.
We present here a simplified method @roughness-transition for determining the minimum height $k_t$ of distributed particles which will be just sufficient to cause the development of premature transition to turbulent boundary-layer flow.

We first define a parameter $eta_k$, which may be used as a nondimensional representation of a given roughness particle of height $k$:
$ eta_k = k / (2x) sqrt(R_x) $ <eq:roughness-parameter>
where $R_x = U_infinity x / nu$, and $x$ is the distance from the leading edge (or nose).
A _roughness Reynolds number_ $R_k$, based on particle
// === page 92 ===
height and flow velocity at the point in the boundary layer corresponding to the top of the particle, is also defined as
$ R_k = (k u_k)/nu $

It is possible to express $eta_k$ as a function of $R_k / sqrt(R_x)$, assuming the velocity and temperature distribution throughout the boundary layer is known.
In @roughness-transition, these calculations have been carried out for the cases of two-dimensional flow past a flat plate and three-dimensional flow past a conical body held with its axis parallel to the stream.
The relationships thus obtained are presented graphically in Figures #ref(<fig:roughness-flat-plate>, supplement: none) and #ref(<fig:roughness-cone>, supplement: none).
To use these charts, it is necessary to choose a value of the _critical_ roughness Reynolds number $(R_k)_t$.
Attempts to measure $(R_k)_t$ experimentally have yielded values anywhere from 250 to 600, but @roughness-transition suggests that the higher value is the most accurate.
Once $(R_k)_t$ is selected, the value of $k$ required to induce transition at a given distance $x$ from the nose or leading edge can then be determined by calculating the ratio $(R_k)_t / sqrt(R_x)$ and reading the corresponding value of $eta_k$ from Figure #ref(<fig:roughness-flat-plate>, supplement: none) or #ref(<fig:roughness-cone>, supplement: none)\; this value of $eta_k$ is used in @eq:roughness-parameter to give
$ k_t = (2 x eta_k)/sqrt(R_x) $ <eq:critical-particle-size>

#figure(
  image("../../assets/figures-original/fig3-19.png"),
  caption: [$eta_k$, the nondimensionalized roughness particle height required to cause transition from laminar to turbulent flow, plotted as a function of $;R_k/sqrt(R_x)$, the ratio of the "roughness Reynolds number" to the square root of the "station Reynolds number" for a flat plate at zero angle of attack.]
) <fig:roughness-flat-plate>

#figure(
  image("../../assets/figures-original/fig3-20.png"),
  caption: [$eta_k$, the nondimensionalized roughness particle height required to cause transition from laminar to turbulent flow, plotted as a function of #mi("\\frac{R_k}{\\sqrt{R_x}}"), the ratio of the "roughness Reynolds number" to the square root of the "station Reynolds number" for a cone whose axis is at zero angle of attack.]
) <fig:roughness-cone>

By way of example, if we take $(R_k)_t$ as 600 and base $R_x$ on $U_(infinity)$ = #qty("60", "m/s"), we have
#[
  #set math.equation(numbering: none)
  $ ((R_k)_t) / sqrt(R_x) = 0.299 / sqrt(x) quad "(for " x " given in meters)" $
]
Suppose, now, we want to know the particle size needed to induce
// === page 93 ===
// Figure 19
// Figure 20
// === page 94 ===
transition at a distance of #qty("3", "cm") (#qty("0.03", "m")) from the nose or leading edge of the surface in question.
The quantity $(R_k)_t / sqrt(R_{X})$ is then 1.73; from the graphs we find the associated two-dimensional value of $eta_k$ is 1.20, while the three-dimensional value is 0.96.
Substituting in @eq:critical-particle-size, we then calculate critical particle sizes $k_t$ of #qty("2.08e-4", "m") for the two-dimensional case and #qty("1.66e-4", "m") for the three-dimensional case.
The two-dimensional results may be applied with good accuracy to fins, body tubes of constant diameter, and other surfaces of zero pressure gradient; the three-dimensional results are applicable to nosecones, shoulders, and similar components whose boundary-layer pressure gradients are favorable.
In either case, the critical size of distributed roughness particles is found to be on the order of 1/100 of a centimeter--further demonstration of the necessity for a smooth surface finish on model rockets to minimize the skin-friction drag.
It should also be noted that the case of our example has an $R_x$ of #num("1.206e5"), which is well above the lower limit of #num("6e4") given in @boundary-layer-theory as the Reynolds number below which a laminar flow _cannot be disturbed_ into a turbulent pattern.
Hence, transition _can_ occur under the conditions given in the example.

There are certain limitations to this method.
First, a zero pressure gradient has been assumed in its derivation; it seems likely, however, that the pressure gradient on most reasonably well-designed model rockets is small enough to keep the method accurate enough for practical use.
Second, the critical roughness Reynolds number $(R_k)_t$ can be assumed to have the constant value of 600 only if the roughness elements are
// === page 95 ===
completely submerged in the laminar boundary layer.
The height of the roughness particles compared with the boundary-layer thickness can be determined from the value of $eta_k$ found for a particular case and the boundary-layer velocity profiles of Figures #ref(<fig:laminar-velocity-profiles-3d>, supplement: none) (a) and #ref(<fig:laminar-velocity-profiles-3d>, supplement: none) (b) @roughness-transition.
The values of $eta_k$ found for the example above are seen to lie well within the boundary layer.

#figure(
  image("../../assets/figures-original/fig3-21.png"),
  caption: [Boundary layer velocity profiles for laminar flow over flat plates (a) and cones (b).]
) <fig:laminar-velocity-profiles-3d>

The reader should note at this point that the variable $eta$ as used in @roughness-transition, from which Figures #ref(<fig:roughness-flat-plate>, supplement: none) through #ref(<fig:laminar-velocity-profiles-3d>, supplement: none) are taken, is not the same as the variable $eta$ used in the presentation of the Blasius solution of @sec:laminar-boundary-layer.
If we identify the $eta$ of @roughness-transition as $eta_3$ and the $eta$ of Blasius by $eta_B$, we have
3 as $eta_3$ and the $eta$ of Blasius by $eta_B$, we have
$ eta_3 = y/(2x) sqrt(R_x) = y/(2x) sqrt((U_(infinity) x)/nu) = y/2 sqrt(U_(infinity)/(nu x)) $
$ eta_B = y sqrt(U_(infinity)/(nu x)) $
so that
$ eta_B = 2 eta_3 $
The two-dimensional boundary-layer profile of @fig:laminar-velocity-profiles-3d (a) is thus identical to that of @fig:blasius-velocity-profile, except for a scale factor of two in the vertical coordinate.

The station $x$ = #qty("3", "cm") generally corresponds to a position on the nosecone or fins of a model rocket.
As $x$ is increased, the boundary layer becomes thicker (varying as $sqrt(x)$ for a laminar boundary layer in zero pressure gradient) and the particle size required to induce transition at that value of $x$ is also increased.
Eventually, the increase in downstream distance from the nose or leading edge will result in a value of $R_x$ sufficiently great
// === page 96 ===
// Figure 21
// === page 97 ===
to cause natural transition without the presence of any surface roughness.
Calculations of induced transition due to surface roughness are, of course, applicable only for values of $R_x$ less than the critical Reynolds number $R_("crit")$.

An increase in the free-stream velocity will decrease the boundary-layer thickness at a given station $x$, so the particle size required to cause premature transition will also decrease.
High-performance model rockets, which are expected to travel at extreme velocities, therefore require exceptionally smooth surface finishes to minimize their friction drag.

Finally, we should note a third limitation on the general applicability of the calculation method presented in this section: the "distributed" roughness particles are actually assumed to lie in a thin band transverse to the stream direction so that the given value of $R_x$ can apply to them all, and the transition induced by particles of diameter $k_t$ is presumed to occur instantaneously as the air flows over this band.
In actuality, of course, the roughness in a model rocket's finish is usually distributed fairly evenly over the entire surface of the rocket and the transition induced by the particles occurs at some finite distance downstream of them.
The calculation method presented does, however, provide the kind of order-of-magnitude information useful to the model rocketeer in ascertaining the permissible roughness of surface finishes that will avoid premature transition and keep friction drag as low as possible.

==== Skin-Friction Drag of Boundary Layers with Transition <sec:skin-friction-transition>
// === page 98 ===
One can estimate the skin-friction drag on a flat plate on which boundary-layer transition occurs if it is assumed that, behind the transition point, the turbulent boundary layer behaves as if it had been turbulent all the way from the leading edge.
Since the laminar region introduces a reduction in drag from what the drag would be if the entire boundary layer were turbulent, we can just substitute the laminar drag up to the transition point for the turbulent drag over the same distance @boundary-layer-theory.
The incremental decrease in drag force is then
$ Delta D = -rho/2 U_(infinity)^2 b x_"crit" [(c_f)_"turb" - (C_f)_"lam"] $
where $(C_f)_"turb"$ and $(C_f)_"lam"$ are the respective coefficients of turbulent and laminar skin friction.

The change in overall skin-friction coefficient becomes
$ Delta C_f = -x_("crit")/(ell) [ (C_f)_("turb") - (C_f)_("lam") ] $
or
$ Delta C_f = -R_("crit")/(R_ell) [ (C_f)_("turb") - (C_f)_("lam") ] $
Letting
$ B = R_"crit" [ (C_f)_"turb" - (C_f)_"lam" ] $ <eq:100>
we derive the overall skin-friction coefficient as @boundary-layer-theory:
$ C_f = (0.074)/(R_ell^(1/5)) - B/(R_ell) $ <eq:101>
where the laminar and turbulent skin-friction coefficients are evaluated from the previously derived expressions, @eq:86 and @eq:63:
// === page 99 ===
#set math.equation(numbering: _ => "(102a)")
$ (C_f)_"turb" = 0.074 / (R_ell)^(1/5) $
#set math.equation(numbering: _ => "(102b)")
$ (C_f)_"lam" = 1.328 / (R_ell)^(1/2) $
#set math.equation(numbering: "(1)")
#counter(math.equation).update(102)
Approximate values of B for several possible values of $R_"crit"$ are listed below @boundary-layer-theory:

#table(
  columns: 5,
  stroke: none,
  table.hline(),
  [$R_"crit"$], [$3 times 10^5$], [$5 times 10^5$], [$1 times 10^6$], [$3 times 10^6$],
  table.hline(stroke: 0.5pt),
  [_B_], [1050], [1700], [3300], [8700],
  table.hline(),
)

In order to apply @eq:101 in a particular case, the value of $R_("crit")$ must be known.
Since no value of this quantity has been determined for a model rocket, we shall assume an average value for calculation purposes of $R_"crit" = num("5e5")$, corresponding to a $B$ of about #num("1700").
Since this value is near the lower end of the $R_"crit"$ range for flat plates (#numrange("3e5", "3e6")), the results obtained should be somewhat conservative, making it unlikely that the drag will be underestimated.
@sec:zero-lift-drag-calc discusses the matter of critical Reynolds number for model rockets further in the light of data gathered by Mark Mercer.
The transition curve described by @eq:101 for $B = 1700$ is plotted as function C in @fig:skin-friction-coefficient, along with the pure laminar and pure turbulent functions from @eq:63 (function A) and @eq:86 (function B).
@fig:skin-friction-coefficient can be used directly to find skin-friction coefficients for use in the method described in @sec:zero-lift-drag-calc.

#figure(
  image("../../assets/figures-original/fig3-22.png"),
  caption: [Skin friction coefficient for flow over a flat plate with boundary layer transition, based on the assumption of $R_"crit"$ = #num("5e5") (corresponding to $B = 1740$ in @eq:101).]
) <fig:skin-friction-coefficient>

=== Three-Dimensional Corrections to the Flat-Plate Skin-Friction Coefficients <sec:3d-skin-friction>
Approximate methods have been developed for estimating
// === page 100 ===
// Figure 22
// === page 101 ===
the effects of three-dimensionality on the values of the skin-friction coefficients derived for the flat plate.
The results of an approximate method described in Reference 9, which can be used to correct two-dimensional skin-friction coefficients for application to three-dimensional surfaces, are presented below.

==== Body Corrections <sec:body-corrections>
For laminar boundary-layer flow over a circular cylinder held with its axis parallel to the stream, the increase in skin-friction coefficient over that of a two-dimensional plate having the same length $l$ is given approximately by @fluid-dynamic-drag
$ (Delta C_f)_("lam") = (2 ell/d)/(R_ell) $ <eq:laminar-body-skin-friction-correction>
In a previous example, we determined a skin-friction coefficient of 0.00382 for laminar flow over a flat plate at a Reynolds number of #num("1.206e5").
For a model rocket body with a length-to-diameter ratio of 10 at the same Reynolds number, we obtain
#{ set math.equation(numbering: none); $ (Delta C_f)_("lam") = 1.66 times 10^(-4) $ }
The adjusted skin-friction coefficient is thus
#{set math.equation(numbering: none); $ (C_f')_"lam" = (C_f)_"lam" + (Delta C_f)_"lam" = (1.328)/(R_ell^(1/2)) + (2 ell/d)/(R_ell) = .003986 $}
with @eq:laminar-body-skin-friction-correction accounting for a 4.4% increase in the value of $C_f$.

In the case of turbulent flow, the increase in skin-friction coefficient is found from @fluid-dynamic-drag
// === page 102 ===
$ (Delta C_f)_"turb" = (.022(ell/d))/((R_ell)^(1/5)) (C_f)_"turb" $
or, since $(C_f)_"turb" = .074/R_ell^(1/5)$ for a flat plate,
$ (Delta C_f)_"turb" = (1.6 times 10^(-3)(ell/d))/((R_ell)^(2/5)) $ <eq:turbulent-body-skin-friction-correction>
In our turbulent-flow example, it will be recalled that the skin-friction coefficient for a completely turbulent boundary layer over a flat plate at a Reynolds number of #num("1.206e6") was found to be 0.0045.
Assuming a length-to-diameter ratio of 10 and the same Reynolds number, we have for the cylinder
#{set math.equation(numbering: none); $ (Delta C_f)_"turb" = 5.93 times 10^(-5) $}
Then the adjusted skin-friction coefficient is
#{set math.equation(numbering: none); $ (C_f')_"turb" = .074 / (R_ell)^(1/5) + (1.6 times 10^(-3)(ell/d)) / (R_ell)^(2/5) = .0045593 $}
with @eq:turbulent-body-skin-friction-correction accounting for a 1.3% increase from the flat-plate value--a bit less than 1/3 the percentage increase for the laminar case.
In @sec:zero-lift-drag-calc, corrections of these magnitudes will be used to determine the skin-friction drag on the constant-diameter body tube sections of a model rocket.

==== Fin Corrections <sec:fin-corrections> 
A model rocket fin is generally not quite thin enough to be represented as a flat plate.
The average tangential velocity of the airstream about a fin with a symmetrical airfoil section is higher than that of the undisturbed flow, even at zero angle of attack when the fin produces no side force (or "lift", as the side force is sometimes colloquially called) @fluid-dynamic-drag.
The
// === page 103 ===
friction drag coefficient of a flat plate wetted on both sides, with the planform area (area of one side only) used as the reference area, is 
$ C_D_f = 2C_f $
Now the increase in friction drag with thickness is proportional to the increment in dynamic pressure caused by the increase in flow velocity required for the air to negotiate a fin of finite thickness.
This increment, in turn, is proportional to the _thickness ratio_ $t/c$, where $t$ denotes fin maximum thickness and $c$ denotes fin chord:
$ (Delta C_D_f) / (2 C_f) = (Delta q) / q = 2 t/c $
Then for the fin drag coefficient, based on fin planform area, corrected for thickness effects, we obtain
$ C'_D_f = 2 C_f (1 + 2 t/c) $ <eq:108>
For a typical model rocket fin having a thickness ratio of 0.05 the correction introduced by the use of @eq:108 is seen to be 10%.

Again, we shall have occasion to return to these formulae in @sec:zero-lift-drag-calc.
In that section also, procedures for converting skin-friction drag coefficients based on body tube lateral area and fin planform area to coefficients based on maximum frontal area will be presented.

// === page 104 ===
== Pressure Drag <sec:pressure-drag>
=== Introduction <sec:pressure-drag-intro>

Pressure drag was defined previously in @sec:basic-concepts as the integral over the body surface of the components of pressure forces acting directly opposite the direction of the rocket's motion; that is,
$ D_p = integral.double_S p cos(arrow(n), arrow(V)) dif s $
where the unit vector $hat(n)$ is everywhere normal to the surface (you may wish to refresh your memory in regard to the notation by consulting @fig:surface-integral-notation again).
For purposes of analysis, it is useful to divide this integral into two parts: first, the integral over the base area of the rocket, called base drag, which will be discussed in @sec:base-drag; and second, the integral over the remainder of the rocket body and fins (pressure foredrag), to be discussed in @sec:forebody-fin-pressure-drag.

The existence of pressure drag is intimately associated with the phenomenon of _boundary-layer separation_.
In general, for a rocket with a streamlined nose, streamlined fin profile, and no launch lug, the base drag will be considerably larger than the pressure foredrag.
This is because separation of the boundary layer from the rear of the rocket, unavoidable due to the presence of the opening into which the engine casing must be inserted, creates a relatively large component of pressure drag.
In the event that extensive flow separation occurs on the forebody, however--as the result of blunt surfaces directed against the airflow--the pressure drag of the forebody can
// === page 105 ===
be quite large, perhaps several times the base drag.

Since an understanding of the mechanism and prevention of boundary-layer separation is essential to the study of pressure drag, we begin with a discussion of this phenomenon in @sec:bl-separation.
Unfortunately, there is very little quantitative information available concerning the two most important sources of pressure drag on well-constructed model rockets: the launch lug (if the model has one) and the base.
@sec:forebody-fin-pressure-drag discusses Mark Mercer's data concerning the first question, and in @sec:base-drag the empirically-derived expression which is used to evaluate base drag is presented, although it is noted that this formula does not take into account either the effects of stabilizing fins or the influence of the engine exhaust on the base drag.

=== Boundary-Layer Separation <sec:bl-separation>
The skin-friction coefficients which were derived in @sec:viscous-drag for laminar and turbulent flow presuppose that the boundary layer remains attached to the solid surface on which it is formed.
This assumption is generally valid for a flat plate, as the pressure gradient along the plate's surface $(dif p)/(dif x)$ is zero; but in regions of _increasing_ pressure ($(dif p)/(dif x)$ positive, a so-called _adverse_ pressure gradient) the boundary layer may be unable to follow the contour of the body surface beyond a certain point and it will break away from the surface.
When this happens, the skin-friction coefficients of @sec:viscous-drag are not applicable beyond the point of separation.

To illustrate this phenomenon, we examine the flow past a blunt body, such as the circular cylinder shown in
// === page 106 ===
@fig:cylinder-flow.
In the inviscid flow of a "perfect" fluid, the fluid elements are _accelerated_ from point A to point B, and are _decelerated_ from point B to point C.
In accordance with Bernoulli's equation, there is an increase in static pressure between A and B and a corresponding decrease along the downstream surface from B to C.
This theoretical pressure distribution (which appears in @fig:cylinder-pressure as the curve $C_p = 1 - 4 sin^2 phi.alt$) is _impressed upon_ the boundary layer in real fluid flow; that is, at any station in the boundary layer the pressure over the thickness of the layer is virtually constant and is taken as equal to the pressure in the exterior flow at the same station.

#figure(
  image("../../assets/figures-original/fig3-23.png"),
  caption: [Flow about a circular cylinder held transverse to the airstream.
  Inviscid ("potential") theory predicts that the flow near the surface of the cylinder will be accelerated from point A to point B and decelerated again from B to C.
  In actuality, the boundary layer develops an inflection point due to the adverse pressure gradient between B and C, and separation occurs at S.]
) <fig:cylinder-flow>

#figure(
  image("../../assets/figures-original/fig3-24.png"),
  caption: [Theoretical and experimental variation of pressure coefficient in flow about a circular cylinder.
  The theoretical curve obtained from potential flow theory is displayed and compared with average curves of experimental data taken at the subcritical Reynolds number $6 times 10^4$ and the supercritical Reynolds number $3 times 10^5$ (based on cylinder diameter).
  The angle $phi.alt$ is the angle between a line drawn from the cylinder axis to point A in @fig:cylinder-flow and a line drawn from the axis to any other point on the cylinder periphery.
  Point B in @fig:cylinder-flow thus corresponds to $phi.alt = 90 degree$ and point O to $phi.alt = 180 degree$.]
) <fig:cylinder-pressure>

An element in the exterior flow, because of the pressure distribution, undergoes a continual change in kinetic energy as it moves from the front to the rear of the cylinder, first increasing, then decreasing.
Because there is no dissipation of energy in inviscid flow, the theory of perfect fluids predicts that a fluid element will arrive at C with the same velocity it had at A.
Within the boundary layer, however, fluid elements are subjected to large frictional forces which consume much of the kinetic energy gained in travelling from A to B.
Hence an element near the wall will not have sufficient kinetic energy to overcome the positive pressure gradient on the downstream side of the cylinder, and at some point its motion will be arrested.
Acting under the influence of the pressure gradient, it will then _reverse_ the direction of its motion so that it is actually moving _against_ the exterior airstream.

This process and its consequences are depicted in @fig:boundary-layer-separation, which shows how the velocity profiles in the boundary layer
// === page 107 ===
// Figure 23
// === page 108 ===
// Figure 24

// === page 109 ===
are altered near a point of separation.
The boundary layer has a full, stable velocity profile at point a, well upstream of the separation point c.
As the flow moves into the region of increasing pressure, however, the particles at the wall begin to be retarded until, at c, the velocity profile develops an inflection point and has a zero velocity gradient at the wall.
The layer of fluid nearest the wall has consequently lost all its forward momentum.
The condition of zero normal velocity gradient at the wall is expressed mathematically as
$ ((partial u)/(partial y))_(y=0) = 0 $

Downstream of c, the separation point, the layers of fluid nearest the wall reverse their motion, a vortex is formed, and the general accumulation of fluid in the boundary layer leads to a rapid increase of boundary-layer thickness (points d and e).
The layer becomes so thick, in fact, that the original assumptions which were made in the derivation of the boundary-layer equations (Equations #ref(<eq:boundary-layer-momentum>, supplement: none) and #ref(<eq:boundary-layer-continuity>, supplement: none)) are no longer valid and a "boundary layer" as such can no longer be said to exist.
Hence, the boundary-layer approximations apply only up to the point of separation, and resort must be had to experiment to determine the conditions on the rear of the body from which the flow has separated.

The remarkable series of photographs in @plate:boundary-layer-separation (a) through (j), made by Prandl and Tietjens (Reference @applied-hydro-aeromechanics), illustrates the actual development of separation at the rear of a circular cylinder.

// Plate 4
#figure(
  image("../../assets/figures-original/plate3-4.png"),
  kind: "plate",
  supplement: [Plate],
  caption: [Flow around the rear end of a blunt body, illustrating the onset of boundary layer separation due to an adverse pressure gradient.]
) <plate:boundary-layer-separation>
// === page 111 ===
#figure(
  image("../../assets/figures-original/plate3-4(1).png"),
  kind: "plate",
  supplement: [Plate],
  numbering: none,
  caption: [Plate 4 (continued): panels e, g, h, i, j.]
) <plate:boundary-layer-separation-2>

In @plate:boundary-layer-separation (a), the flow has just begun; the boundary layer is very thin, and conditions conform very closely to ideal,
// === page 110 ===
// === page 112 ===
inviscid potential flow.
In the next picture, some particles nearest the wall have been retarded by the adverse pressure gradient; they appear as bright, white dots.
This corresponds to the velocity profile of point c in @fig:boundary-layer-separation.
These particles have acquired a backwards velocity in @plate:boundary-layer-separation (c), and a line of stationary fluid now exists at some distance from the wall, as at points d and e in @fig:boundary-layer-separation.
The external flow persists in forward (left-to-right) motion outside this line.
The instability of the dividing line is demonstrated in the concluding plates of the sequence as it breaks up into separate vortices, grossly altering the pressure distribution beyond the separation point.

#figure(
  image("../../assets/figures-original/fig3-25.png"),
  caption: [The development of boundary layer separation from a surface due to the influence of a positive (adverse) pressure gradient.]
) <fig:boundary-layer-separation>

@fig:cylinder-pressure compares the theoretical pressure distribution $(C_p = 1 - 4 sin^2 phi)$ on a circular cylinder with experimental results obtained at various Reynolds numbers.
Because of the symmetry of the theoretical curve, integration of the pressure forces over the surface of the cylinder will yield a pressure drag of zero --- the same result obtained for an object of any shape using potential-flow theory alone.
In the experimental cases, however, the pressure over the rear of the cylinder never attains its original value at $phi = 0 degree$ .
_Pressure recovery_ is thus said to be _incomplete_.
The suction forces due to the negative pressure coefficient at the rear will predominate over the suction forces acting on the upstream side, and a net positive pressure drag (force in the direction of the stream) will result.

The existence of a point of inflection in the velocity distribution is a necessary condition for separation @boundary-layer-theory.
// === page 113 ===
// Figure 25
// === page 114 ===
In @sec:viscous-drag we saw that the stability of a laminar flow is also related to this characteristic of the velocity profile: the existence of a point of inflection is a necessary _and sufficient_ condition for the amplification of turbulent disturbances.
The significance of this correlation is revealed when one considers the variation of the drag coefficient of a sphere or circular cylinder with Reynolds number, as shown in @fig:drag-vs-reynolds-blunt.

#figure(
  image("../../assets/figures-original/fig3-26.png"),
  caption: [Variation of drag coefficient with Reynolds number based on diameter for circular cylinders (a) and spheres (b).
  The curves shown are average values obtained from a large number of experiments.]
) <fig:drag-vs-reynolds-blunt>

At a Reynolds number of about $num("3e5")$ for a sphere, and about $num("5e5")$ for a circular cylinder held transverse to the flow, the drag coefficient exhibits a sudden and considerable decrease.
This phenomenon is due to the transition of the boundary layer from laminar to turbulent flow, causing the separation point to move downstream --- and, therefore, causing the total width of the "stagnant" or "dead-air" region created by the separation to decrease.
This effect is also demonstrated in the experimental pressure distributions of @fig:cylinder-pressure, as for supercritical (post-transition) Reynolds numbers, the pressure recovery is more complete than at subcritical (pre-transition) Reynolds numbers.
Hence the fluid flow resembles frictionless flow more closely, and the pressure drag is correspondingly reduced.
The magnitude of the _decrease_ in _pressure_ drag is considerably greater than the _increase_ in the _friction_ drag due to the attached turbulent boundary layer.
This accounts for the sharpness of the drag coefficient curve's slope at the critical Reynolds number.

A striking flow-visualization experiment, originally performed by Prandtl @applied-hydro-aeromechanics, demonstrates the validity of these assertions.
// === page 115 ===
// Figure 26
// === page 116 ===
He placed a sphere in subcritical flow and observed the resulting flow pattern, made visible by smoke (@plate:sphere-flow (a)).
As expected, the laminar flow separated just before the shoulder, and there was a very wide wake trailing the body.
When a thin wire ring was mounted upstream of the sphere's equator, artificially inducing turbulence as a subcritical Reynolds number (see @sec:bl-transition), the separation point moved well downstream as shown in @plate:sphere-flow (b).
This movement was accompanied by a decrease in the measured drag coefficient, similar to that achieved at supercritical Reynolds numbers.
The experiment is thus a convincing demonstration that the sharp decline in the drag coefficient of spheres and cylinders observed at the critical Reynolds number can only be interpreted as a boundary-layer phenomenon @boundary-layer-theory.

It remains to be explained why transition affects the position of the separation point.
The physical phenomenon determining this behavior is that _a turbulent boundary layer can withstand a stronger adverse pressure gradient than can a laminar boundary layer_.
This results from the mixing action present in the turbulent layer, which transfers momentum from the outer layers of the flow to the strata of fluid near the wall, permitting them to continue their forward motion for greater distances against adverse pressure gradients than would otherwise be the case.
This same mechanism accounts for the low drag of many bodies with streamlined aftersections, such as airplane fuselages: the transition of the boundary layer to turbulent flow prevents the flow from separating in the relatively mild adverse pressure gradient at the rear of such a body, and
// === page 117 ===
// Plate 5
// === page 118 ===
thus the pressure drag is very small.
Since the skin friction of such a body in fluids such as air is also small, the overall drag coefficient is close to zero.

#figure(
  image("../../assets/figures-original/plate3-5.png"),
  kind: "plate",
  supplement: [Plate],
  caption: [Flow about a sphere at a subcritical Reynolds number.
  In (a) the laminar boundary layer separates slightly upstream of the shoulder.
  In (b) the presence of a wire ring "trips" the boundary layer, artificially inducing transition to turbulent flow and delaying separation until the flow is far downstream of the shoulder.]
) <plate:sphere-flow>

=== Pressure Drag of the Forebody and Fins <sec:forebody-fin-pressure-drag>
From our discussion of separation, we derive a cardinal rule for low-drag model rocket design: _never present a blunt surface to the flow_.
In general, there are four areas on a typical model rocket which are capable of violating this rule: the body base, the launching lug or other protuberances (if present), the leading and trailing edges of the fins, and the nosecone.
Although at least a portion of the base of any model rocket must necessarily be cut off abruptly to permit insertion or removal of the rocket engine, boattailing offers a considerable reduction in base drag and will be discussed separately later on.
In the present section, we shall examine the effects of separation on the rest of the rocket body and fins and describe techniques for minimizing them.

==== Nosecone (Forebody) Pressure Drag <sec:nosecone-pressure-drag>
For the purposes of analysis, it is possible to consider the nosecone of a model rocket as being attached to a body tube of effectively infinite length oriented with its axis parallel to the flow.
Such a configuration is known as a _half-body_.
An expression for the drag on such a body is a good approximation to the pressure drag on the forebody (nosecone and body tube) of an actual model rocket, provided that the rocket is long enough so conditions near the base do not have a sizeable influence on the flow near the nose.
The data of Mark Mercer's
// === page 119 ===
investigation suggest that this approximation is a good one for a typical model rocket, since Mercer found changes in nosecone shape to cause the same absolute increment in drag coefficient for both the blunt-finned and the streamline-finned version of the model he tested.

We first examine the flow about a half-body for an incompressible, inviscid --- that is, perfect --- fluid @applied-hydro-aeromechanics.
The mathematics of this problem are such that it cannot be solved unless some specifications are made regarding the pressure at the rear of the body.
To circumvent this difficulty, aerodynamicists assume that, at a sufficient distance from the nose, there exists a slot into which the surrounding pressure penetrates (@fig:half-body-pressure-drag).
The pressure drag on such a half-body is then the resultant integral of pressure over the surface of the "amputated" forebody.

#figure(
  image("../../assets/figures-original/fig3-27.png"),
  caption: [Scheme for computing the pressure drag of a half-body.
  $A_1$ is the frontal cross-section area of the control surface; $A_2$ is the frontal cross-section area of the half-body.]
) <fig:half-body-pressure-drag>

The techniques of potential-flow theory, involving the mathematical concepts of sources and sinks, could be used to obtain the pressure drag, but a simpler model is presented here @applied-hydro-aeromechanics.
As in @fig:half-body-pressure-drag, we enclose the half-body in a wide, hollow cylinder and integrate over a right, cylindrical control surface as indicated by the dotted line.
Denoting the cross-sectional area of the cylinder as $A_1$, and the frontal area of the half-body as $A_2$, the requirement of mass conservation yields
$ A_1 u_1 = (A_1 - A_2) u_2 $
or, letting $R_a = A_2 / A_1$.
// === page 120 ===
// Figure 27
// === page 121 ===

$ u_1 = (1 - R_a) u_2 $
Bernoulli's equation for steady, incompressible flow requires that
$ p_1 + 1/2 rho u_1^2 = p_2 + 1/2 rho u_2^2 $ <eq:113>
so one can write
$ p_1 - p_2 = rho/2 u_2^2 [1 - (1 - R_a)^2] $

Drag, it will be recalled, represents the _momentum flux_ through the control surface (as in the friction-drag calculations of @sec:viscous-drag).
Hence,
$ D = A_1 (p_1 - p_2) + A_1 rho u_1^2 - (A_1 - A_2) rho u_2^2 $ <eq:115>
Applying the condition of mass conservation, 
$ D = A_1 (p_1 - p_2) + A_1 rho u_1 (u_1 - u_2) $ <eq:116>
From @eq:113, then, 
$ D = A_1 rho/2 u_2^2 {1 - (1 - R_a)^2 + 2 [(1 - R_a)^2 - 1 + R_a]} $ <eq:117>
Finally, simplifying the algebra, one obtains @eq:118 
$ D = A_1 rho/2 u_2^2 R_a^2 = A_2 rho/2 u_2^2 R_a $ <eq:118>
or $C_D = R_a $.
If we let the cross-sectional area $A_1$ of the enclosing cylinder become infinitely large, $R_a$ goes to zero --- resulting in the prediction that the drag of a half-body in a fluid flow of infinite extent is zero.

A better understanding of this result can be had by examining
// === page 122 ===
the pressure distribution over the nose of the half-body under the assumption that the flow remains attached to the surface.
The streamlines (@fig:half-body-streamlines (a)) near the stagnation point are _convex_ toward the body; this causes an excess pressure in that region.
As the flow proceeds downstream along the nose, however, the streamlines turn their _concave_ sides to the body, indicating the existence of a diminished pressure.
The net effect, as can be seen in @fig:half-body-streamlines (b), is an equilibrium between positive pressures and suction (negative pressure increments), yielding zero pressure drag.

#figure(
  image("../../assets/figures-original/fig3-28.png"),
  caption: [Streamlines and pressure distribution in flow about a half-body.
  Drawing (a) shows the streamline pattern and the ratio of local static pressure to free-stream dynamic pressure, while drawing (b) shows the distribution of pressure over the surface.
  Note that there is positive pressure on the forward part of the nose region and suction on the after portion of the nose.
  According to potential theory the two effects counteract each other and the drag of a half-body is zero.]
) <fig:half-body-streamlines>

Although this result was derived for inviscid flow, it has important applications to real fluid flow.
Consider, for instance, a nose shape with a smooth, gently-sloping profile, such as a paraboloid or tangent ogive.
We do not expect the flow over such shapes to differ much from that predicted by potential theory, as separation does not occur.
The streamlines will be displaced outward some small distance by the boundary layer, but they will retain essentially the same contours.
Hence, it seems reasonable to assume that the pressure drag of a streamlined nosecone should be very close to zero in real fluid flow.

There is a considerable body of experimental data supporting this contention.
@fig:nose-foredrag-coefficients, due to Hoerner @fluid-dynamic-drag, presents a variety of possible nose shapes with their tested values of pressure foredrag coefficient (based on frontal cross-sectional area).
As we surmised, the first two shapes, having no sharp edges or blunt surfaces, have pressure drag coefficients near zero.
Furthermore, as the "degree of bluntness" increases
// === page 123 ===
// Figure 28
// Figure 29
// === page 124 ===
(from top to bottom in the diagram) the drag coefficient shows a corresponding increase.

#figure(
  image("../../assets/figures-original/fig3-29.png"),
  caption: [Pressure foredrag coefficients of various nose shapes.
  The rounded shapes exhibit very low drag coefficients, in good agreement with the potential-flow prediction for a half-body.]
) <fig:nose-foredrag-coefficients>

Evidently the first shape, which might represent a conic section (ellipsoid, paraboloid, or hyperboloid of revolution), is superior for model rocketry applications; in fact, an ellipsoid of revolution whose length is about twice its base diameter is considered near-optimum by many designers.
Its negative pressure drag coefficient is due to the predominance of suction forces over positive pressure increments on its surface.
This result can be understood by reexamining the experimental pressure distributions determined for a circular cylinder held transverse to the flow.
The flow over the forward half of the cylinder is the two-dimensional analog of the three-dimensional flow about a nosecone of rounded profile, and it can be seen that integration of the coefficient of pressure over the cylinder's forward half ($phi <= 90 degree$) will result in a negative pressure drag coefficient.

A comparison of shapes \#3 and \#6 reveals what even a small amount of rounding of sharp edges can accomplish.
The quantitative variation of drag coefficient with "rounding radius" for a variety of two-dimensional and three-dimensional shapes is illustrated in @fig:rounding-radius-drag.
At a value of $r/h approx 0.1$ for three-dimensional shapes, $C_D$ declines sharply in a manner analogous to its behavior at the critical Reynolds number (@fig:drag-vs-reynolds-blunt).
The physical cause of this behavior is not transition, however, but a progressive _decrease in separation_ from the forward edges.
The "critical radius ratio" $r/h = 0.1$ is then the minimum value above which the effects of separation on the pressure drag are
// === page 125 ===
// Figure 30
// === page 126 ===
// === page 127 ===
// Figure 31
// Figure 32
// === page 128 ===
negligible.
It appears from tests that $(r/h)_(c r i t)$ is a slowly-varying function of Reynolds number, decreasing as $R$ is increased.

#figure(
  image("../../assets/figures-original/fig3-30.png"),
  caption: [Variation of drag coefficient with rounding radius for two-dimensional and three-dimensional bodies.
  The two-dimensional result can be applied to fin design, while the three-dimensional curve is applicable to nosecones.
  Both curves are averages of experimental data.]
) <fig:rounding-radius-drag>

Mark Mercer @altitude-performance has wind-tunnel tested all seven of the shapes in @fig:nose-foredrag-coefficients, plus some additional ones of interest, on an actual model rocket --- the Javelin, a commercially-available kit produced by the Centuri Engineering Company, which he modified to various configurations for test purposes.
The trend toward greater drag with increasing nosecone bluntness is clearly demonstrated in his measurements (@fig:javelin-nose-drag).
Note particularly that the five shapes exhibiting the lowest drag (Centuri stock nosecones, catalog numbers BC-70, BC-78, BC-72, BC-76 and BC-74) are roughly similar to the first shape in @fig:nose-foredrag-coefficients; furthermore they are representative of what might be considered "typical" model rocket nosecones.
The essential features which distinguish these shapes from the others tested are (a) a length-to-diameter ratio of at least 2; (b) a smooth transition between nosecone and body, the nosecone being generally tangent to the tube at its base; (c) a smooth boundary curve with its convex side toward the flow; and (d) no blunt surfaces facing the flow.
Mercer's data may thus be considered an empirical guide to model rocket nosecone streamlining.

#figure(
  image("../../assets/figures-original/fig3-31.png"),
  caption: [Drag coefficient of the Javelin rocket with various nosecone shapes and fin profiles.
  The first column displays diagrams of the nose shapes tested.
  The second lists designations for the shapes (designations beginning with BC- are catalog numbers used by the Centuri Engineering Company, producers of the cones and of the Javelin rocket).
  The third column lists drag coefficients obtained for the Javelin rocket sanded, painted, and with airfoiled fins using each nose shape.
  The fourth column lists drag coefficients obtained for a sanded and painted Javelin with no airfoiling on the fins.
  Figures in parentheses were obtained after adding a launch lug; the figure in brackets is for an unsanded, unpainted Javelin with a launch lug and without fin airfoiling.]
) <fig:javelin-nose-drag>

The importance of the length-to-diameter ratio in nosecone streamlining is demonstrated quantitatively in @fig:paraboloid-fineness-drag, taken from Stine @handbook-model-rocketry.
The pressure drag coefficient is reduced significantly as the ratio $L/d$ of the paraboloidal shape is increased up to about 2.0; further extension of the nose reduces the drag only slightly.
This behavior accounts for the relatively slight differences in drag among the five streamlined nosecones
// === page 129 ===
in Mercer's tests.

#figure(
  image("../../assets/figures-original/fig3-32.png"),
  caption: [Variation in the drag coefficient of a paraboloidal nose shape with fineness ratio L/d.]
) <fig:paraboloid-fineness-drag>

==== Fin Pressure Drag <sec:fin-pressure-drag>
Since the fin surfaces are generally parallel to the flow direction, any pressure drag due to the fins must result from separation of the flow from the leading and/or trailing edges.
Mercer's data indicate that the effect of blunt fin edges, as opposed to streamlined edges, is considerable in this respect (@fig:javelin-nose-drag).
The Javelin rocket used in his tests experienced an increase in $C_D$ from 0.70 to 2.35 when all the fin edges were left squared off, rather than rounded at the leading edges and tapered at the trailing edges --- a 236% increase in drag over that of the streamlined-fin configuration.

At the thickness-to-chord ratios commonly encountered in model rocketry (usually 0.02 or greater), the separated flow from a blunt leading edge will reattach itself to the fin at some point downstream.
If the trailing edge is also squared off, separation will occur there also, resulting in a "base drag" analogous to that of the rocket's main body.

To prevent --- or rather, to minimize --- fin separation, streamlining of the fin section (or "profile") is required.
Adequate streamlining can usually be accomplished simply by providing a rounded leading edge (the two-dimensional analogy to the streamlined nose shape) and a gently-sloping aftersurface culminating in a sharp trailing edge (the so-called "knife-edge").
One must compromise with structural durability requirements here, since a paper-thin trailing edge is very easily damaged.
The profile of a well-streamlined model rocket fin is illustrated
// === page 130 ===
in @fig:fin-lift-induced-drag.
The character of the lateral edges of the profile --- whether they are flat or "airfoiled" --- does not substantially affect pressure drag, but it does play an important role in determining drag due to lift as discussed in @sec:other-drag.

==== Launch Lug Drag <sec:launch-lug-drag>
A remarkable aspect of aerodynamic drag is that small changes in the shape of a body can produce large variations in its drag coefficient.
Mercer's research showed that the addition of a launch lug (presumed location: near the rear of the body tube) increased the $C_D$ of the streamlined-fin version of his Javelin test rocket by about 0.28, or 67% of the value for a lugless rocket.
This finding agrees rather well with estimates of 50% or more reported for much larger rockets @exterior-ballistics.

The culprit, once again, is boundary-layer separation -- in this case, from the blunt face of the lug.
Pressure drag due to lugs and similar objects which protrude from the boundary layer is often referred to as _parasitic drag_.
The only available data on this important effect as it relates to model rockets is that of Mercer, so the influence of a launch lug on the $C_D$ values of rockets of different body diameters and fin configurations, as well as the effects of launch lug placement, cannot now be accurately assessed.
We note, however, that the addition of a lug to the blunt-finned version of Mercer's Javelin increased the drag coefficient by about 0.21, an increment roughly equal to that for the streamline-finned version.
On this basis it is possible to suggest an average drag coefficient increment
// === page 131 ===
of $Delta C_D = 0.25$ due to the presence of a launch lug on model rockets whose configurations are such that the ratio of body diameter to lug diameter is identical to that of Mercer's Javelin, and such that the lug placement is similar.

We can develop a tentative formula for extending Mercer's results to models in which the launch lug diameter stands in a different ratio to the body tube diameter than was the case in the Javelin experiments, by computing the drag coefficient of the launch lug when in place based on its own included frontal area.
To do this we note that the standard launch lug used on a model of the Javelin's size has a diameter of about 0.40 centimeter, while the body tube of the Javelin has an outer diameter of 1.93 centimeters.
The ratio of the tube diameter to the lug diameter is then 4.8, and the ratio of $A_r$, the reference area for computing the drag of the entire rocket (which, it will be recalled, is equal to the cross-sectional area of the body tube), to the area included within the circular cross-section of the lug --- which we shall denote by $A_("lug")$ --- is the square of the diameter ratio, or $A_r / A_("lug") = 23.0$.
The drag coefficient of the lug based on _its own_ frontal area is therefore 23 times greater than that based on the body tube cross-sectional area.
Denoting it by $(C_D)_("lug")$, we have $(C_D)_("lug") = 5.75$ --- quite a large value, and one that indicates that the lug must cause flow separation, not only from itself, but from a substantial area of the body tube in its vicinity.
The general expression for the drag coefficient increment due to a body-mounted launch lug may then be written
// === page 132 ===
$ (Delta C_D)_"lug" = 5.75 A_"lug"/A_r = 5.75 (d_"lug"/d_r)^2 $ 

Data taken by Douglas J. Malewicki @drag-coefficient-measurements indicate that placing the launch lug in one of the joints between the model's fins and its body can substantially decrease the launch lug drag increment.
Malewicki determined an overall $C_D$ of about 0.50 for his Skychute XI rocket tested _with_ a launch lug at Reynolds numbers ($R_ell = num("2.5e5")$) about the same as those of Mercer's tests.
Since, according to the methods of @sec:zero-lift-drag-calc, the $C_D$ of the Skychute XI without a launch lug is probably not less than 0.35, the increment in $C_D$ due to the presence of the lug located at the fin-body joint cannot be much more than 0.15 --- only 60% of the increase determined by Mercer for a body-mounted lug on a configuration of the same ratio $A_("lug")/A_r$.
The wind tunnel used by Malewicki (the low-speed tunnel at Wichita State University near Wichita, Kansas) may have had a significantly lower air turbulence level than that used by Mercer, so it is not necessarily accurate to compare their results directly.
Given the extremely limited nature of the data concerning this important problem presently available to model rocketeers, however, the best we can do is to present the following tentative formula for the drag coefficient increment due to a launch lug mounted at the fin-body joint: 
$ (Delta C_D)_("lug") = 3.45 A_"lug"/A_r = 3.45 (d_"lug"/d_r)^2 $
The development of accurate, empirical expressions for $(Delta C_D)_("lug")$ covering variations in lug configuration, size, and placement is a problem requiring considerable further research.

// === page 133 ===
The most effective means of reducing launch lug drag is to eliminate the lug completely and launch from a tower or closed-breech launching device.
Mechanisms by which the lug can be retracted soon after launch or left behind on the launch rod have also been experimented with, resulting in varying degrees of success.
One firm, Competition Model Rockets of Alexandria, Virginia, has developed a particularly successful form of pop-off launch lug and has incorporated the design in several commercially-available kits.

In conclusion, however, I must reiterate that the prediction of drag due to launch lugs remains at the time of writing almost wholly a matter of empirical art --- of "guesstimating", to adopt a colloquialism from professional rocketry.
It is hoped that in the near future this area of model rocket drag will be more thoroughly investigated, and that formulae for predicting launch lug drag will be established on a firmer analytical foundation.

=== Base Drag <sec:base-drag>
The only section of the rocket now remaining to be considered in our analysis of pressure drag is the base.
Since the plane of the base is generally perpendicular to the flow direction (at zero angle of attack), base pressures act along the drag axis and the second term in @eq:pressure-drag-expanded may be written simply as
$ D_b = -integral.double_(S_b) p_b dif S_b $ <eq:121>
// === page 134 ===
so
$ C_D_b = D_b/(1/2 rho U_infinity^2 S_b) $

Theoretical analysis of the base drag is extremely difficult; in fact, there is at this time no theory which can accurately predict the base drag of a model rocket during all phases of flight.
Complications arise from the following sources: 
#set enum(numbering: "a)")
+ The boundary layer separates from the blunt base and, as mentioned previously, the boundary-layer equations are not valid beyond the separation point; 
+ The presence of the fins disturbs the flow, generally resulting in a decrease in base drag from that observed for finless bodies; and 
+ A jet exhausting into the base region is believed to cause a further decrease in base drag.
The last two problems, peculiar to rocketry, have not been well researched on either the hobby or the professional level for subsonic flow.
The empirical expression for base drag presented here is consequently unable to take either of the last two phenomena into account.

Base drag is essentially a separation phenomenon.
@fig:base-flow-boattail depicts the flow to be expected about the base of a model rocket when the engine is not firing.
The boundary layer separates and then converges downstream, enclosing a volume known as the "dead-air" region.
This term is actually a misnomer, as there is considerable motion of the air in this region
// === page 135 ===
// Figure 33
// === page 136 ===
resulting from mixing along the _free shear layer_ -- the boundary region between the dead-air volume and the free stream -- and from flow reversal at the convergence point @review-base-drag.

#figure(
  image("../../assets/figures-original/fig3-33.png"),
  caption: [Flow about the base of a model rocket with a conical boattail.
  $epsilon$ is the boattail angle and $delta$ is the boundary-layer thickness.
  The boundary layer thickens as the flow passes over the boattail and then separates when the flat base is reached, forming a region of low pressure --- the "base pressure" $p_b$ --- and then reattaching at point R downstream of the rocket.
  Viscous effects cause the circulation pattern shown in the base pressure region.]
) <fig:base-flow-boattail>

The character of the flow as a whole, as Hoerner @fluid-dynamic-drag suggests, is somewhat like a jet pump: the external flow, acting as a "jet", mixes with the "dead air" and tries to "pump" it away.
The static pressure at the base is consequently reduced, and base drag results (see @eq:121).
The boundary layer (which becomes the free shear layer after separation), however, acts as an insulating sheet between the jet pump effect of the outer flow and the dead-air region, and the effective dynamic pressure of the pump is reduced.
An increase in boundary-layer thickness therefore results in a smaller reduction of base pressure, which in turn implies a smaller base drag.

We have seen that the boundary-layer thickness is proportional to the skin-friction drag (for example, compare @eq:54, @eq:59, and @eq:60).
If we now define a forebody friction drag coefficient $C_(f b)$ such that
$ C_(f b) = D_"forebody, friction"/(q S_b) C_f ' S_s/S_b $ <eq:123>
where $S_s$ is the wetted area of the body exclusive of the base, $S_b$ is the area of the base, and $C_f '$ is the forebody skin-friction coefficient as determined by the methods of @sec:viscous-drag, we expect (on the basis of the above discussion) that
$ C_D_b = f(C_(f b)) $ <eq:124>
The nature of this relationship -- that is, the form of the
// === page 137 ===
function $f$ -- can be determined from a plot of experimental data, as in @fig:base-drag-vs-friction.
The empirical function that has been determined for @eq:124 is
$ C_D_b = 0.029/sqrt(C_(f b)) eq.triple D_b/(q S_b) $ <eq:125>
As we expected, an increase in the body viscous drag (which includes the effects of roughness) produces a decrease in base drag.
@eq:125, however, as previously stated, does not take into account the effects of fins or rocket exhaust.

Although there has been some experimentation with trading increased friction drag for reduced base drag by varying the roughness of a model's surface finish, model rocketeers are generally limited to variations in rocket geometry to effect reductions in base drag.
The most widely-used technique, employed on models which require a main body tube section greater in diameter than that which would be a "glove fit" to the engine, is referred to as _boattailing_.
A gradually-tapered section (see @fig:base-flow-boattail) is added to the rear of the rocket body, to guide the flow downstream to a reduced base area.
If the boattail angle $epsilon$ is small enough (about 5 or 10 degrees) the flow will not separate from the boattail lateral surface, and the increase in base pressure due to pressure recovery along the boattail reduces the base drag.
The technique is limited in usefulness to those models which, for some reason, must use a main body section significantly greater in diameter than the engine casing; there is, of course, no sense in enlarging the diameter of a rocket just to enable it to be built with a boattail!
// === page 138 ===
// Figure 34
#figure(
  image("../../assets/figures-original/fig3-34.png"),
  caption: [Variation of the base drag coefficient of a body of revolution with forebody friction drag coefficient.
  The curve and semiempirical function shown represent a "best fit" to a large collection of experimental data.]
) <fig:base-drag-vs-friction>

// === page 139 ===
An expression for the base drag of a boattailed configuration can be developed from @eq:125.
If the body maximum frontal area is denoted $S_m$, and its associated body diameter $d_m$, then
$ S_b = S_m ((d_b)/(d_m))^2 $ <eq:126>
The friction drag coefficient of the forebody based on maximum body frontal area is
$ C_D_f = D_"forebody"/(q S_m) $
Now
$ C_("fb") = D_("forebody")/(q S_b) = ( D_("forebody")/(q S_m) ) ( (d_m)/(d_b) )^2 = C_D_f ( (d_m)/(d_b) )^2 $
Furthermore,
$ (C_D_B)_m = D_b/(q S_b) = D_b/(q S_b) ( d_b/d_m )^2 = C_D_b ( d_b/d_m )^2 $
where $(C_D_b)_m$ is the base drag coefficient based on maximum body frontal area.
Then
$ (C_D_b)_m = ( d_b/d_m )^2 0.029/sqrt(C_D_f ( d_m/d_b )^2) $
or, simplifying algebraically,
$ (C_D_b)_m = ( d_b/d_m )^3 0.029/sqrt(C_D_f) $ <eq:131>

It is apparent that $(C_(D b))_m$ can be reduced, either by decreasing the ratio $d_b/d_m$ or by increasing the skin-friction drag of the body.
The first technique is limited by the diameter of the engine itself.
The danger of separation from the boattail as the boattail angle $epsilon$ (as defined in @fig:base-flow-boattail) is
// === page 140 ===
increased also imposes a lower limit on $d_b/d_m$ for a given boattail length.
The maximum permissible value of $epsilon$ generally lies somewhere between $5 degree$ and $10 degree$; if $epsilon$ is greater than this value separation will occur on the boattail and @eq:131 will not apply.

Increasing the skin-friction drag of the body can be accomplished by lengthening the boattail, but it can be demonstrated from @eq:131 that the boattail should not be longer than the section of cylindrical body tube it replaces; or more precisely, that the rocket with boattail should not be any longer than it would have been if designed without a boattail.
Differentiation of @eq:131 with respect to $C_(D_f)$ gives
$ (dif (C_(D_b))_m)/(dif C_(D_f)) = -((d_b)/(d_m))^3 0.029/(2 (C_(D_f))^(3/2)) $ <eq:132>
where care must be taken to distinguish the letter $dif$ as used to denote differentiation on the left-hand side from $d$ as used to denote diameter on the right, and the assumption has been made that $d_b/d_m$ is unrelated to $C_(D_f)$.
Since, for the increase in skin-friction drag to be less than the decrease in base drag, we require $Delta(C_(D_b))_m < -Delta(C_(D_f))$ ,
$ -(d_b/d_m)^(3) 0.029/(2 C_D_f)^(3/2) < -1 $
giving
$ (C_D_f)^(3/2) < .0145 ( d_b/d_m )^3 $
and finally,
$ C_D_f < .059 ( d_b/d_m )^2 $ <eq:135>
// === page 141 ===
The largest value of $C_(D_f)$ for which an increase in $C_(D_f)$ will result in a decrease in overall drag occurs for the limiting case $d_b/d_m = 1.0$, and even then $C_(D_f)$ must be less than 0.059.
Model rockets do not have body skin-friction drag coefficients this small.
A typical value of $C_(D_f)$ for a well-designed model rocket is three or more times this value (see @sec:zero-lift-drag-calc).
This is because well-designed model rockets have a _fineness_ (length-to-diameter) ratio sufficiently great so that the ratio of wetted area to frontal area is relatively large, and so, therefore, is $C_(D_f)$.
Hence, insofar as @eq:131 is valid, the contention that an increase in $C_(D_f)$ cannot result in a decrease in base drag sufficient to lower the overall drag of the rocket is proved.
Note that the _means_ by which $C_(D_f)$ is to be increased has not been specified in the derivation, and that @eq:135 consequently refers to variations in $C_(D_f)$ effected by any means whatsoever; i.e., whether by altering the length of the body to change $S_s$ or by altering the surface finish of the body to change $C_f '$.
@eq:135 therefore indicates, not only that a rocket should not be lengthened to incorporate a boattail, but that it should not be roughened in the hope that increasing $C_(D_f)$ will decrease $C_(D_b)$ enough to lower the overall drag coefficient of the model.
Having determined to design a model with a boattail no longer than it would have been without one, the modeler may follow Stine @handbook-model-rocketry who suggests a boattail length of two or three body diameters for best results at moderate ratios $d_b/d_m$.

A recent experimental investigation @base-drag-recessing indicates that recessing the base of a boattailed configuration may be an effective means of reducing base drag.
Since the nozzle of a
// === page 142 ===
model rocket engine provides a natural concavity at the base, this technique, although not regarded as such, has been in use for some time.
By recessing the engine slightly into the tube, thereby creating a deeper concavity, it may be possible to reduce base drag still further.
Care must be taken not to recess the engine further than about half a body diameter, or the conditions of nozzle overexpansion responsible for the notorious Krushnic effect (named for Richard Krushnic, who discovered it in 1958) will be created, destroying most of the effective thrust (and probably the aft section of the model).
Those readers desiring a further explanation of this interesting phenomenon may consult the article by Gordon Mandell in _Model Rocketry_ magazine for November, 1969.

== Other Contributions to Model Rocket Drag <sec:other-drag>
=== Introduction <sec:other-drag-intro>
The two preceding sections examined the contributions to drag of the tangential (viscous) and normal (pressure) forces acting on a model rocket body.
Several important assumptions were inherent in these presentations; namely that (a) the body was inclined at zero incidence (zero angle of attack) to the flow; (b) the body was not rotating about its longitudinal axis; and (c) surface roughness affected the drag only through inducement of premature transition.
We are now interested in determining the effects on the drag of relaxing these assumptions.

The determination of tail-body drag at angle of attack is extremely difficult, because little is known about tail-body interference effects at different flow inclinations.
We will
// === page 143 ===
restrict our attention to small angles of attack (less than about $10 degree$, since at larger values of $alpha$ the relationship between drag and angle of attack is far more complex and, in any case, flight at large angles of attack generally indicates a dynamic stability problem necessitating a redesign of the rocket.
Furthermore, only very simple single-stage model rocket configurations will be examined.
@sec:aoa-drag presents a practical method (from Reference @datcom) for calculating the drag coefficient at angles of attack, although (as with many methods discussed in this chapter) it still requires experimental data to confirm its applicability to model rockets.

In @sec:rotation-drag we examine the effects of rotation about the roll axis, which generally produces a drag increase.
It will be found that the increase in drag coefficient due to spin is usually small compared to that due to the mechanism which induces the rotation (usually canted fins).

Previously, in @sec:surface-roughness, it was seen that surface roughness due to single or distributed particles can lead to premature transition, and hence to an increase in the skin friction.
In a purely turbulent region surface imperfections, since they represent obstacles to the flow, have a viscous drag of their own.
This component of model rocket drag will be examined in @sec:roughness-drag.

=== Drag at Small Angles of Attack <sec:aoa-drag>
Due to forces which may arise from causes such as wind gusts, off-center thrust, misaligned fins, or staging transients, a model rocket may assume an angle of attack $alpha$ to the instantaneous
// === page 144 ===
velocity vector, as seen in @fig:trial-rocket.
If the vehicle is aerodynamically stable the angle is usually quite small and quickly reduced by the restoring moment and damping moment characteristic of a stable model.
During the time in which the response to the disturbance produces discernable angles of attack, however, the drag may be increased considerably.
A knowledge of the extent to which the drag coefficient of a given rocket increases with angle of attack is therefore of considerable value.
In Sections #ref(<sec:body-aoa-drag>, supplement: none) and #ref(<sec:fin-aoa-drag>, supplement: none) expressions will be presented for estimating the increase in drag coefficient of the body and tailfin assembly alone, respectively, with angle of attack.
The magnitude of the corrections required due to fin-body interference will be discussed in @sec:fin-body-interference-drag, and the overall variation of $C_D$ with angle of attack, as found by experiment and through semiempirical formulae, is analyzed in @sec:total-aoa-drag.

==== Body Drag at Angle of Attack <sec:body-aoa-drag>
The drag of a slender body (such as that of a model rocket) at an angle of attack is closely related to its side force (if any) and drag at zero angle of attack.
The total drag coefficient of a model rocket body (nosecone plus cylindrical body tube, but excluding fins, launch lugs, and any other protuberances) at a nonzero angle of attack can be expressed as
$ C_(D_B) = (C_(D_0))_B + C_(D_B)(alpha) $
where
$(C_(D_0))_B$ is the body drag at zero angle of attack.
// === page 145 ===
A detailed method of estimating this quantity is presented in @sec:zero-lift-drag-calc.
A typical value for a slender model rocket is $(C_(D_0))_B = 0.27$ at a Reynolds number of $num("1e6")$.
This coefficient includes base drag.
$C_(D_B)(alpha)$ is the drag coefficient of the body due to angle of attack (the notation is read " $C_(D B)$ as a function of $alpha$ ", or simply " $C_(D B)$ of $alpha$ "), which will be discussed herein.

When a model rocket assumes a very small angle of attack (about 2 degrees or less), the external flow is not significantly disturbed from its behavior at zero incidence.
Since it was shown in @sec:pressure-drag that (for a streamlined nose) this external flow resembles closely that predicted for an inviscid fluid, it is reasonable to attempt the use of potential flow theory for the determination of aerodynamic forces at very small angles of attack -- and, indeed, such analyses have been carried out.
The forces produced are a side force, perpendicular to the free-stream flow direction, and a much smaller drag force, parallel to $U_(infinity)$.

Potential theory predicts a side force (also referred to as "lift") coefficient which varies linearly with angle of attack.
According to Van Dyke @datcom, the body lift-curve slope at zero incidence is given by
$ (dif C_L)/(dif alpha) = (2(k_2 - k_1))/(S_m) S_0 $ <eq:137>
so that the lift coefficient $C_L$ is given by
// === page 146 ===
$ C_L = (2(k_2-k_1) S_0)/S_m alpha $ <eq:138>
Applying the approximation $sin (alpha) approx alpha$, valid for small angles, we then have 
$ C_D_B (alpha) = alpha C_L = (2(k_2-k_1) S_0)/S_m alpha $ <eq:139>
where 
/ $(k_2 - k_1)$: is the "apparent mass factor" as determined by Munk, given in @fig:apparent-mass-factor as a function of body fineness ratio.
/ $x$: is the distance from the nosecone tip measured along the longitudinal body axis.
/ $x_0$: is the body station where the flow ceases to obey the predictions of potential theory.
 This location can be found from the expression 
$ x_0 = 0.55 x_1 + 0.36 ell_B $ <eq:140>

/ $x_1$: is the body station where the rate of change of cross-sectional area with $x ((dif S_x) / (dif x))$ first reaches its minimum value.
/ $S_x$: is the body cross-sectional area at station $x$.
/ $S_0$: is the body cross-sectional area at $x_0$.
/ $S_m$: is the maximum body cross-sectional area.

These terms will be clarified when a numerical example is computed shortly.
It should be noted that @eq:140
// === page 147 ===
// Figure 35
// Figure 36
// === page 148 ===
has been constructed by slope and intercept extrapolation from a graph contained in Reference @datcom, and that the validity of this extrapolation has not as yet been demonstrated.

#figure(
  image("../../assets/figures-original/fig3-35.png"),
  caption: [Apparent mass factor ($k_2 - k_1$) as a function of body fineness ratio ($l_b / d$).]
) <fig:apparent-mass-factor>

As the angle of attack increases beyond about two degrees, separation of the boundary layer from the leeward side of the body occurs and potential theory no longer yields an accurate result; the _normal_ (i.e., perpendicular) forces, and hence the lift, increase nonlinearly with angle of attack.
The flow in the boundary layer exhibits a component in the circumferential direction due to the increasing magnitude of _viscous cross-flow forces_.
Theories have been developed which take account of these effects by adding to the potential-flow solution of @eq:138 and @eq:139 another, viscous term.
The method we will present here assumes, as before, that the flow is potential over the forward part of the body and that there is no viscous contribution to drag due solely to the angle of attack.
On the aft part of the body, where the flow is assumed entirely viscous, lift and drag arise solely from cross-flow forces.
Then, according to Hopkins @datcom,
$ C_L = (2(k_2 - k_1) S_0)/(S_m) alpha + (2 alpha^2)/(S_m) integral_(x_0)^(l_b) eta r_x C_D_c dif x $ <eq:141>
$ C_D_B (alpha) = (2(k_2 - k_1) S_0)/(S_m) alpha^2 + (2 alpha^3)/(S_m) integral_(x_0)^(l_b) eta r_x C_D_c dif x $ <eq:142>
where 
/ $eta$: is the ratio of the cross-flow drag on a cylinder of _finite_ length to the cross-flow drag on a cylinder of _infinite_ length, given in @fig:cylinder-length-drag;
// === page 149 ===
/ $C_D_c$: is the experimental steady-state cross-flow drag coefficient of a circular cylinder of infinite length.
 $C_(D c)$ is equal to 1.2 for all practical model rocket problems;
/ $r_x$: is the body radius at any station $x$.

#figure(
  image("../../assets/figures-original/fig3-36.png"),
  caption: [Ratio of the drag coefficient of a circular cylinder of finite length to the drag coefficient of a circular cylinder of infinite length, $eta$, as a function of cylinder fineness ratio ($l_b / d$).]
) <fig:cylinder-length-drag>

The reader is reminded here that @eq:138, @eq:139, @eq:141, and @eq:142 must be applied using $alpha$ given in radians rather than degrees.
In most cases, @eq:142 is quite simple to apply to model rockets, as $x_0$ (the station where the external flow ceases to be potential) usually occurs downstream of the nosecone-body joint.
The quantity $S_0/S_m$ thus usually equals 1.0, and the integral, since $eta$, $r_x$, and $C_D_c$ are all constant along the aft section of a rocket having no shoulder or boattail, involves only an exact differential $dif x$.
In such a case,
$ integral_(x_0)^(ell_b) eta r_x C_D_c dif x = (ell_b - x_0) eta r_x C_D_c $ <eq:143>

In order to acquire some "feel" for the kind of numerical results one obtains from @eq:142, we shall employ the simple, single-stage model rocket configuration shown in @fig:trial-rocket.
Its length, 13 inches (33 cm.) and body diameter, 0.813 inch (2.06 cm.), are identical to the corresponding dimensions of the Aerobee-Hi for which Stine @handbook-model-rocketry has reported the experimentally-determined variation of the total $C_D$ with $alpha$.
We do not seek or expect good agreement with Stine's data, as the methods of this and the following sections are approximate, and as the trial rocket is somewhat different from the Aerobee-Hi.
Specifically, the trial rocket has 4 fins as opposed to 3 for the Aerobee-Hi,
// === page 150 ===
// Figure 37
// === page 151 ===
a different fin shape, no launch lug, and is without the Aerobee's longitudinal fairings.
Comparing the experimental results with analytical predictions for a rocket of roughly similar configuration, however, will give us a "feel" for whether our results are, in the colloquialism of engineering, "in the right ball park".

#figure(
  image("../../assets/figures-original/fig3-37.png"),
  caption: [Trial rocket used to compute drag increase due to nonzero angle of attack.
  All dimensions are given in centimeters.]
) <fig:trial-rocket>

From @fig:trial-rocket, $ell_b/d = 16$, for which @fig:apparent-mass-factor yields $(k_2 - k_1) = 0.97$.
The quantity $dif S_x / dif x$ attains its minimum value, zero, at the body-nosecone junction, so $x_1 = 8.9$ cm.
We determine $x_0$ from @eq:140 as follows:
#math.equation(block: true, numbering: none)[
	$x_o = 0.55(8.9) + 0.36(33) = 16.8$	
]
Since $x_0$ is located on the cylindrical body, $S_0/S_m = 1.0$; the first term in @eq:142 then becomes
#math.equation(block: true, numbering: none)[
	$2(k_2 - k_1) (S_0)/(S_m) alpha^2 = 1.94 alpha^2$	
]
From @fig:cylinder-length-drag, $eta = 0.74$.
The body radius $r_x$ is a constant, 1.03 cm., between $x_0$ and $ell_b$ .
Hence,
#math.equation(block: true, numbering: none)[
  $ (2 alpha^3)/(S_m) eta r_x C_D_c (ell_b - x_0) &= alpha^3 [ (2 times .74 times 1.03 times 1.2 times 16.2)/(pi times (1.03)^2) ] \
 &= 8.86 alpha^3 $
]
Finally, we obtain
$ C_D_c (alpha) = 1.94 alpha^2 + 8.86 alpha^3 $ <eq:144>

This coefficient is based on maximum body frontal area $S_m$.
For $alpha = 0.022$ radian (about $1.25 degree$ ), the $alpha^2$ term is at least ten times greater than the $alpha^3$ term.
This essentially defines the range of validity for the potential-flow solution.
The
// === page 152 ===
// Figure 38
// Figure 39
// === page 153 ===
// === page 154 ===
two terms are of equal magnitude at $alpha = 12.5 degree$.
It should be noted here that $C_D_B (alpha)$ is independent of velocity, a result which agrees with the predictions of slender-body theory for incompressible flow.

==== Fin Drag at Angle of Attack <sec:fin-aoa-drag>
A model rocket fin, which is here assumed to have a symmetrical, streamlined section profile, will behave like an aircraft wing when it is inclined at an angle to the flow.
It will naturally produce a side force, or "lift", as shown in @fig:fin-lift-induced-drag -- which, after all, is why rockets have fins in the first place.
Due to the deflection of the flow in the vicinity of the fin, however, the total aerodynamic _normal force_ $N$ will not be perpendicular to the free-stream flow.
Instead, it is turned backwards to some angle $alpha_i$ to the line perpendicular to the free stream, so that it exhibits a drag component.
This drag component is known as the _induced drag_ of the fin, and its associated drag coefficient is denoted $C_D_i$.

#figure(
  image("../../assets/figures-original/fig3-38.png"),
  caption: [The origin of induced drag.
  The fin is held at an angle of attack $alpha$, causing the force $arrow(F)$ to act through the center of pressure.
  $arrow(F)$ is tilted back at the angle $alpha_i$ and is resolved into lift $arrow(L)$ and induced drag $arrow(D)_i$.]
) <fig:fin-lift-induced-drag>

As in the case of the body, the induced drag of a fin is related to the lift force it produces.
One cannot, however, obtain an expression for $C_D_i$ unless he has specific knowledge of the _distribution_ of lift on the fin.
We shall assume for the purposes of our numerical example that the following values given by Hoerner @fluid-dynamic-drag for a rectangular wing of aspect ratio $A R = "span"/"chord" = 3$ with sharp chordwise edges are valid for the trial rocket:
// TODO: A side by side equation like this could use some better formatting.
#math.equation(block: true, numbering: none)[
  $ (dif alpha^degree)/(dif C_L) = 18.6 $
  $quad quad quad$
  $ (dif C_D)/(dif C_L^2) = .123 $
]
// === page 155 ===
Then for $alpha$ given in radians,
#math.equation(block: true, numbering: none)[
  $ (dif alpha) / (dif C_L) = 0.32 $
]
so that
#math.equation(block: true, numbering: none)[
  $ C_D_i = .123 ((alpha)/(.32))^2 = 1.2alpha^2 $
]
This coefficient, based on fin planform area, can be converted to a coefficient based on maximum body frontal area by multiplying by the factor $S_F / S_m$.
We shall assume the angle of attack to exist entirely about the x-axis (yaw) or y-axis (pitch) of the rocket, so that only two fins are producing lift.
Then
#math.equation(block: true, numbering: none)[
  $ (S_F)/(S_m) = (7.14 times 2.54)/(pi (1.03)^2) = 5.42 $
]
$ C_D_i ' = 5.42 times 1.2 alpha^2 = 6.51 alpha^2 $ <eq:145>
You should note here that the fin planform area used includes the imaginary extension of the fins within the body tube, and that "planform" refers to the fact that only the area of one side of the fins is used.

The assumption of square chordwise edges (squared tips) in the above calculations is of some significance, as the shape of the fin tip can affect the value of the induced drag considerably.
When a fin is producing lift, it has a lower pressure on its upper, or "suction" side, than on its lower side.
This phenomenon is associated with the formation of _trailing vortices_ (see @fig:trailing-vortices (a)) near the fin tips as the air from below tries to "curl up" around the tips.
Depending on the fin tip shape, the distance between the resulting vortex cores may be less than the
// === page 156 ===
actual span of the fins, leading to a reduction in effective span -- and therefore, to a reduction in effective aspect ratio.
@fig:trailing-vortices (b) depicts several possible fin-tip shapes, with their changes in effective aspect ratio $Delta A R$ and the location of the vortex core in each case.
Those shapes for which $Delta A R$ is positive or zero are most desirable, since they produce low induced drag.
Of the shapes shown, this category would include numbers 1, 5, and 6.
One shape not shown, but popular among designers of high-performance model rockets, is the _elliptical_ fin.
During the 1930's it was shown mathematically that, for airplane wings of moderate aspect ratio and without twist ("washin" or "washout" at the tips), an elliptical planform gives the least induced drag for a given lift.
Elliptical or near-elliptical wing planforms were subsequently incorporated into several fighter planes of the World War II era, most famous among them being the Supermarine Spitfire of the English Royal Air Force.
It is not known for certain whether the elliptical planform retains its advantage in the presence of a body tube of diameter commensurate with the fin span, and in fact the testing of model rocket fin planform shapes for induced drag is currently a pressing need which, it is hoped, advanced hobbyists will shortly fulfil.
Nevertheless, the elliptical planform is currently preferred by a number of successful competition modelers.

#figure(
  image("../../assets/figures-original/fig3-39.png"),
  caption: [Trailing vortices and effective aspect ratio.
  An airplane wing or a pair of diametrically opposed rocket fins sheds trailing vortices from its tips (a).
  As viewed from behind the wing the left vortex rotates clockwise; the right one counterclockwise as shown.
  The vortices descend after leaving the wing and also "tuck in" slightly, reducing the effective span of the wing and therefore reducing the effective aspect ratio, since the aspect ratio $cal(R)$ is defined as the span divided by the average chord.
  Panel (b) shows the change in effective aspect ratio and vortex core position (dotted line) measured for a number of different tip shapes on wings of $cal(R) = 3.0$.
  Since wings of higher $cal(R)$ can generate a given lift at lower angle of attack and lower induced drag than wings of lower $cal(R)$, zero or positive values of $Delta cal(R)$ are desirable.]
) <fig:trailing-vortices>

==== Fin-Body Interference Drag at Angle of Attack <sec:fin-body-interference-drag>
The subject of interference drag at angle of attack is prohibitively difficult to handle theoretically.
Consequently, we shall rely entirely upon semiempirical determinations here.
// === page 157 ===
The term "interference drag" refers to the increment in drag a complete configuration possesses over the sum of the drags of its separated, component parts.
At the fin-body joints there is a joining and thickening of boundary layers, leading to increased drag in this region.
Separation is a distinct possibility at such joints, and Stine @handbook-model-rocketry suggests the elimination of sharp corners by glue fillets to minimize this danger.
Hoerner @fluid-dynamic-drag has reported data indicating that interference drag is minimized when the fillet radius is between 4% and 8% of the fin chord at the root.

@datcom gives the following semiempirical expression for interference drag coefficient at angle of attack:
$ Delta C_D_i = [ K_(F(B)) + K_(B(F)) - 1 ] (dif C_L)/(dif alpha) S_e/S_m alpha^2 $ <eq:146>
where
/ $K_(F(B))$: $("fin lift in the presence of the body") / ("fin lift alone") $;
/ $ K_(B(F))$: $("body lift in the presence of the fins") / ("fin lift alone") $;
/ $(dif C_L)/(dif alpha)$: is the lift-curve slope of the fin at $alpha = 0$; and
/ $S_e$: is the exposed fin planform area.
The functions $K_(F(B))$ and $K_(B(F))$ are both given in @fig:fin-body-interference.

#figure(
  image("../../assets/figures-original/fig3-40.png"),
  caption: [Fin-body interference coefficients for flight at nonzero angle of attack.
  d is the diameter of the body tube, while b is the span of a diametrically opposed pair of fins.]
) <fig:fin-body-interference>

We can now determine $Delta C_D_i$ for our trial rocket.
The total fin span $b$ is 7.14 cm. and the body diameter _d_ is 2.06 cm., so $d/b = .289$.
This gives, from @fig:fin-body-interference, $K_(B(F)) = 0.44$ and $K_(F(B)) = 1.25$.
Since only two fins are assumed to be producing
// === page 158 ===
// Figure 40
// Figure 41
// === page 159 ===
lift, $S_e = 12.95 "cm"^2$, and
// TODO: Side by side equation formatting
#math.equation(block: true, numbering: none)[
  $S_m = pi r^2 = 3.33 "cm^2" quad (dif C_L)/(dif alpha) = 1/(.32) = 3.12 $
]
so that
$ Delta C_D_i = (.44 + 1.25 - 1) 3.12 (12.95)/(3.33) alpha^2 = 8.38 alpha^2 $ <eq:147>
The interference drag coefficient due to angle of attack is thus of considerable magnitude; in fact, it is larger than the _sum_ of $C_D_B (alpha)$ and $C_D_i '$, as given by @eq:144 and @eq:145.

==== Total Drag Increase at Angle of Attack <sec:total-aoa-drag>
If we now combine the results of @sec:body-aoa-drag, @sec:fin-aoa-drag, and @sec:fin-body-interference-drag, we obtain an expression for the total drag increment $C_D (alpha)$ due to angle of attack:
$ C_D (alpha) = C_D_B (alpha) + C_D_i ' + Delta C_D_i $ <eq:148>
For our trial rocket, the result is
$ C_D (alpha) = 16.83 alpha^2 + 8.9 alpha^3 $ <eq:149>
This function, along with its constituent functions, is tabulated in @tab:4 and is plotted in @fig:aoa-drag-comparison.
In order to compare @eq:149 with the experimental data for G. Harry Stine's Aerobee-Hi, the trial rocket has been assumed to have the same zero-lift drag coefficient as the Aerobee-Hi (about 0.75).
The trial vehicle would probably have a much lower zero-lift drag coefficient in actuality (unless its surface were very rough), but the assumption of equal zero-lift drag for the two vehicles makes it more convenient to compare their drag increments due to angle of attack.
The agreement between the curves for the
// === page 160 ===
// Table 4
// === page 161 ===
two vehicles is surprisingly close, considering the physical differences between the rockets and the simplifying assumptions made in the derivation of @eq:149 -- a result which tends to confirm the validity of the semiempirical approach.
It is, however, hoped that experiments will be performed in the near future on rockets similar to that of @fig:trial-rocket (with and without launch lug), to determine with greater precision the accuracy of this computational method.

#figure(
  image("../../assets/figures-original/fig3-41.png"),
  caption: [Increase in drag coefficient with angle of attack for the trial rocket of @fig:trial-rocket (semiempirical) and for a scale model Aerobee-Hi tested by G. Harry Stine, assuming the same drag coefficient for both rockets at zero angle of attack.]
) <fig:aoa-drag-comparison>

#figure(
  table(
    columns: 6,
  [Angle of attack $alpha$ (deg)], [Angle of attack $alpha$ (rad)], [Body drag coefficient due to $alpha$: $C_D_B (alpha)$ $1.94 alpha^2 + 8.86 alpha^3$], [Fin drag coefficient due to $alpha$: $C_D_i '$ $6.51 alpha^2$], [Fin-body interference drag coefficient due to $alpha$: $Delta C_D_i$ $8.38 alpha^2$], [Total drag coefficient due to $alpha$: $C_D (alpha)$ $16.83 alpha^2 + 8.9 alpha^3$],

  [0.5],  [.00873], [.000], [.000], [.001], [.001],
  [1.0],  [.0175],  [.001], [.002], [.003], [.005],
  [2.0],  [.0349],  [.003], [.008], [.010], [.021],
  [3.0],  [.0524],  [.007], [.018], [.023], [.048],
  [4.0],  [.0698],  [.012], [.031], [.041], [.084],
  [5.0],  [.0873],  [.021], [.050], [.063], [.136],
  [6.0],  [.1047],  [.032], [.072], [.092], [.196],
  [7.0],  [.1222],  [.045], [.097], [.125], [.267],
  [8.0],  [.1396],  [.062], [.127], [.163], [.352],
  [9.0],  [.1571],  [.082], [.161], [.208], [.451],
  [10.0], [.1745],  [.106], [.198], [.255], [.559]
  ),
  caption: [Increase in drag coefficient with angle of attack for the trial rocket of @fig:trial-rocket.]
) <tab:4>

One fact is clearly established in @fig:aoa-drag-comparison: that the increase in drag at small angles of attack can be a sizeable portion of the zero-lift drag.
For the Aerobee-Hi model, the drag coefficient is doubled at an incidence of ten degrees.
Clearly, then, for maximum altitude performance, it is desirable to design a rocket such that all oscillations resulting from in-flight disturbances are damped out as quickly as possible.

We observe that @eq:149 is dominated by the $alpha^2$ term over the entire range of angles of attack of interest in model rocketry; up to $alpha = 5 degree$, the $alpha^3$ term may be neglected with less than 5% error in the final result.
// TODO: replace chapter references
With respect to determining the coefficient $epsilon$ introduced in Chapter 1 and used in Chapter 4 to compute the effect of dynamic oscillations on altitude capability, however, the modeler will generally want to be conservative.
A conservative determination of $epsilon$ may be made by finding the value of $alpha$ at which $C_D$ is doubled over its zero-lift value, according to @eq:148, and then determining the value of $epsilon$ in the approximate function
$ C_D (alpha) approx (2 epsilon)/(rho S_m) alpha^2 $ <eq:150>
// === page 162 ===
such that the drag is again doubled at this same value of $alpha$.
In the case of our trial rocket, the drag coefficient will be doubled over its zero lift value when $C_D (alpha) = 0.75$.
This occurs for $alpha$ = 0.201 radian, or about $11.5 degree$.
From @eq:150 we find that the value of $(2 epsilon)/(rho S_m)$ required to produce a $C_D (alpha)$ of 0.75 at $alpha$ = 0.201 radian is 18.52, and this would determine the value of $epsilon$ used in determining oscillation effects on altitude performance by the methods presented in Chapter 4.
@eq:150 is conservative (that is, it slightly overestimates the drag) over the range of angles of attack between zero and that at which the drag is doubled -- and for the average model rocket, the $alpha$ at which $C_D$ is doubled marks the upper limit of the range of angles of attack of interest.

=== Drag Due to Rotation <sec:rotation-drag>
A model rocket, rotating about its longitudinal -- or _roll_ -- axis in flight, will experience an increase in drag due to the thickening of the boundary layer resulting from the circumferential velocity of the body tube surface.
We shall denote this circumferential velocity component by $u$.
This thickening of the boundary layer could conceivably cause separation on the forebody and fins, and an increased dead-air volume aft of the base, if $u$ is sufficiently large.

The drag increase due to rotation may be estimated by examining @fig:rotation-drag.
The circumferential velocity is given by
$ u = pi d n $
where $d$ is the diameter of the body and $n$ is the number of
// === page 163 ===
// Figure 42
// === page 164 ===
revolutions per second.
If we assume that the trial rocket of our numerical example (diameter = 2.06 cm.) has been given a roll rate of 100 radians per second (15.9 revolutions/second) at an airspeed of 60 meters (6000 cm.) per second, we obtain
#math.equation(block: true, numbering: none)[
  $ u/U = 0.0172 $
]
The effect of such small ratios of body tube circumferential velocity to vehicle airspeed -- ratios typical of model rockets -- is too small to be read from the curve of @fig:rotation-drag.
One may therefore conclude that, as far as the finless body is concerned, rotation does not exert a significant influence on model rocket drag.

#figure(
  image("../../assets/figures-original/fig3-42.png"),
  caption: [Increase in the drag coefficient of a finless projectile due to rotation (spinning) about the longitudinal axis.
  u is the tangential velocity of the projectile's surface due to the spin; U is the longitudinal free-stream velocity.]
) <fig:rotation-drag>

The mechanism for inducing rotation in a model rocket purposefully is usually fin geometry -- that is, by canting the fins, giving them an asymmetrical section profile, or adding spinnerons.
Of these three techniques, fin canting is the most commonly used.
Since canting merely creates a permanent, artificially-induced angle of attack for the fins, the drag due to fin cant can be estimated using the methods of Chapter 2 and the results of @sec:fin-aoa-drag of the present chapter.
According to @eq:90, @eq:115, @eq:116, and @eq:117 of Chapter 2, canting the fins of our trial rocket will give it a roll rate determined by
$ omega_z = .1672 U theta $ <eq:152>
For $omega_z$ = 100 radians/second at U = 6000 cm./sec., a fin cant angle $theta$ almost exactly 0.1 radian is required (0.1 radian = $5.73 degree$).
Now the effective angle of attack of the fins is always _less_
// === page 165 ===
than the cant angle, since the airflow itself is "canted" as seen by the rotating fins.
To be more precise, the angle of attack varies with radius from the rocket's centerline according to
$ alpha(r) = theta - (omega_z r)/U $ <eq:153>
For the simple, rectangular fins of our trial rocket, the _average_ effective angle of attack can be used to determine the induced drag due to fin cant.
The value of $alpha(r)$ at the fin root is 0.0828, while the value at the tip is 0.0405.
Since $alpha(r)$ varies linearly with radial distance from the centerline, the average effective angle of attack $overline(alpha)$ is just
#math.equation(block: true, numbering: none)[
  $ overline(alpha) = (0.0828 + 0.0405)/2 = 0.0617 $
]
In @eq:145 the induced drag of two of the trial rocket's fins was found to be $6.24 alpha^2$.
In the case of canted fins, all four fins are at the angle of attack $overline(alpha)$; @eq:145 must therefore be doubled to give
$ (C_D_i ')_("cant") approx 12.5 overline(alpha)^2 $ <eq:154>
For the computed $overline(alpha)$ of 0.0617, $(C_D_i ')_c = .0475$.
If the rocket's zero-incidence drag coefficient is .75 without fin cant, this means a 6.34% increase in $C_D_0$.
If a spin rate double that used in the above calculations were desired, it would be necessary to incur four times this drag penalty, or an increase of 25.4% in $C_D_0$ .
These figures, together with the realization that they probably represent minimum values for the drag increase due to fin cant -- they do not account for increased fin-body interference --
// === page 166 ===
indicate that, while the effects of rotation themselves may not be significant, the effects of the mechanism by which rotation is induced are considerable.
Furthermore, there is an increasing danger of separation in the vicinity of the fin leading edges as the angle of cant is increased.
Such separation could result in a gross magnification of pressure drag.
While the angle of cant at which such phenomena become significant has not as yet been established with precision, it has been generally accepted for a number of years that cant angles greater than $15 degree$ produce reductions in performance so severe as to be detectable with the naked eye.

=== Drag Due to Surface Roughness in Turbulent Flow <sec:roughness-drag> 
In @sec:bl-transition we examined the critical height of roughness elements necessary to induce premature transition in the boundary layer from laminar to turbulent flow.
Within the turbulent boundary layer which is prevalent over most of a model rocket at higher Reynolds numbers, roughness can affect the drag in another manner: if the individual roughness particles protrude above the thin laminar sublayer, they will have a viscous drag of their own.
The turbulent skin-friction coefficient derived in @sec:viscous-drag (@eq:86) applies only to "hydraulically smooth" surfaces; that is, surfaces on which the grain size $k$ of roughness particles is less than the thickness of the laminar sublayer.

The _admissible height_ $k_"adm")$ for roughness particles is defined as the maximum height of the particles which gives no increase in the drag compared with a smooth wall.
A simple, conservative formula for determining $k_"adm")$ for a flat plate is @boundary-layer-theory:
// === page 167 ===
$ k_("adm") <= 100 nu/U_(infinity) $ <eq:155>
This relationship is accurate for Reynolds numbers below about $num("1e6")$.
It does not take into account the fact that the boundary-layer thickness increases with distance from the leading edge, and hence that $k_("adm")$ is smaller upstream than downstream.
Its use is justified, however, because it provides values of $k_("adm")$ which are generally smaller than those obtained from the more precise expression @boundary-layer-theory
$ k_("adm") < (7 nu)/(U_(infinity) sqrt(C_f_x)) $ <eq:156>
where $C_f_x$ is the local skin-friction coefficient, given by $(2 tau_0)/(rho U_(infinity)^2)$.
@eq:155 may thus be used for the entire range of model rocket Reynolds numbers without fear of obtaining values of $k_"adm"$ which are too large.

If we let $U = 60$ meters/second, for instance, and $nu = qty("1.495e-5", "m^2/s")$, @eq:155 yields
#math.equation(block: true, numbering: none)[
  $ k_( "adm" ) <= qty("2.48e-5", "meter") = qty("2.48e-3", "cm") $
]
This result applies specifically to sand grains, for which @eq:155 was empirically determined, but it can be used as an approximate guide for other forms of roughness.
Hence, at a velocity typical of model rocket flight, the surface of the model downstream of the transition point may be regarded as hydraulically smooth if the size of distributed roughness grains does not exceed about #qty("0.0025", "cm").
If this condition is satisfied, the smooth turbulent skin-friction coefficient of @sec:viscous-drag may be used in calculations.
It should be noted that the calculated
// === page 168 ===
value of $k_"adm"$ is considerably less than the roughness height required to induce premature transition as determined in @sec:bl-transition.
If the criterion of this section is satisfied, therefore, transition will not be induced prematurely.

@tab:5 provides information on grain sizes in microns (1 micron = #qty("1e-6", "m") = #qty("1e-4", "cm")) for various surfaces.
It indicates that the finish on a model rocket should be about as smooth as that of paint on mass-produced aircraft, or better.
Note that _poorly-sprayed_ paint has a grain size of about 200 microns -- _eight times_ our calculated $k_"adm"$.
A rocket with such a poor finish will have a considerably higher skin-friction coefficient than one that is sufficiently well painted to be hydraulically smooth.
The skin-friction coefficient of a surface having roughness elements sufficiently large that it cannot be considered hydraulically smooth may be found from the semi-empirical formula @boundary-layer-theory
$ C_f = (1.89 + 1.62 log (ell_b)/k)^(-2.5) $ <eq:157>
which is valid for values of $(ell_b)/k$ between $10^2$ and $10^6$ , where $ell_b$ denotes the length of the body (or fin, as the case may be), and the notation "log" denotes the logarithm to the base 10.
According to @eq:157, a body #qty("30", "cm") in length having roughness particles of $k = qty("0.02", "cm")$ will exhibit a friction drag coefficient of
will exhibit a friction drag coefficient of
#math.equation(block: true, numbering: none)[
  $ C_f = 7.63 times 10^(-3) $
]
The corresponding value for a hydraulically smooth body in turbulent flow is #num("4.5e-3") , so in this instance roughness
// === page 169 ===
// === page 170 ===
increases the friction drag by about 70%.
#figure(
  table(),
  caption: [Size of surface roughness elements for various surfaces.]
) <tab:5>

@eq:157 applies only to surfaces which are completely rough; i.e., those for which the height of the roughness elements is everywhere greater than the thickness of the laminar sublayer.
The degree of roughness of a given surface thus depends upon $k/delta$, the ratio of grain size to boundary-layer thickness.
Since $delta$ varies with Reynolds number, a given surface may appear rough or smooth, depending on the value of the free-stream velocity.
If, for example, we examine a turbulent boundary layer over a surface at relatively low Reynolds numbers (around #num("5e5"), the roughness elements may be completely submerged in the laminar sublayer, making the surface appear hydraulically smooth.
As the velocity (and therefore the Reynolds number) increases, the boundary layer becomes thinner, and the roughness elements begin to protrude from the sublayer.
This process is initiated near the nose, or leading edge, where the boundary layer is thinnest, and progresses downstream with increasing $R$.
When a surface is in this "transition" state between a completely smooth and a completely rough appearance, its skin-friction coefficient will have a value intermediate between those determined from @eq:86 and @eq:157.
Note that this process proceeds along a body in a direction opposite to that of laminar-to-turbulent boundary-layer transition, as described in @sec:pressure-gradient-re.

Two final observations can be made regarding drag due to roughness.
First, since @eq:157 is independent of velocity, $C_f$ is a constant for any given ratio $(ell_b)/k$ .
In accordance with @eq:18, it may then be concluded that
// === page 171 ===
hydraulically rough surfaces obey the quadratic drag law exactly.
Furthermore, @eq:155 for $k_"adm"$ is independent of body length; hence _any two_ rockets travelling at the same velocity under identical atmospheric conditions have identical values of $k_"adm"$.
The maximum velocity attained by a rocket determines the minimum value of $k_"adm"$.
If this minimum grain size is not exceeded anywhere on the surface, the rocket may be regarded as hydraulically smooth throughout its flight, and the friction drag equations of @sec:viscous-drag are applicable to the calculation of its drag coefficient.

== Calculation of the Zero-Lift Drag of Simple Model Rockets <sec:zero-lift-drag-calc>
=== The United States Air Force Stability and Control Datcom Method <sec:datcom-method>
In the previous sections we have analyzed in detail the origin of drag forces on model rockets.
Information of this nature is of interest in the design stage, when it is desired to minimize the drag on a vehicle whose size and shape are known to be subject to certain constraints arising from the purpose for which it is built, but whose precise, final form is yet to be determined.
After the construction of the rocket is complete and it stands ready to launch, however, the modeler invariably finds himself asking, "Just how high _will_ it go?".
To answer this question one requires a knowledge of the overall drag coefficient of the model, which can generally be obtained in actual cases only through accurate wind-tunnel or drop tests.
Since the facilities required for such tests are not available to the majority of model rocketeers, most of us must be content
// === page 172 ===
with calculating fairly accurate $C_D$ values from available semiempirical expressions.

This section presents and discusses one such semiempirical method, derived from the _United States Air Force Stability and Control Datcom_ ("Datcom" standing for #emph("Dat")a #emph("Com")pendium).
The existence of this method was first brought to the author's attention through a short paper entitled "A Critical Examination of Model Rocket Drag for Use with Maximum Altitude Performance Charts", a work prepared by Dr.
Gerald M. Gregorek of Ohio State University for presentation at the Eighth National Model Rocket Championships in 1966, and which subsequently received limited distribution to certain interested parties and local sections of the National Association of Rocketry.
Through his compilation of this work, Dr. Gregorek deserves full credit for being the first to apply the Datcom method to model rockets.

The _USAF Stability and Control Datcom_ is a large compilation of semiempirical expressions for evaluating the aerodynamic forces acting on aircraft and missiles in subsonic, supersonic, and hypersonic flight regimes.
It is updated periodically to include new developments in the literature of aerodynamics.
The formulae presented here are taken from the most recent edition available to the author at the time of writing @datcom.
According to the _Datcom_, the zero-lift drag coefficient of a fin-body combination may be represented as
$ (C_D_0)_("FB") = (C_D_0)_F (S_F)/(S_m) + (C_D_0)_B $ <eq:158>
where
// === page 173 ===
/ $S_F$: is the total planform area of all the fins; 
/ $S_m$: is the maximum body cross-sectional area; 
/ $(C_D_0)_F$: is the zero-lift drag coefficient of the fins as derived in @sec:3d-skin-friction, @eq:108:
$ (C_D_0)_F = 2(C_f)_F (1 + 2 t/c) $ <eq:159>
/ $(C_D_0)_B$: is the zero-lift drag coefficient of the body, which is further subdivided into the forebody drag and the base drag:
$ (C_D_0)_B = (C_D_f)_b + C_D_b $ <eq:160>
where
$ (C_D_f)_b = (C_f)_b [1 + 60/((ell_b/d_m)^3) + 0.0025((ell_b)/(d_m))] (S_s)/(S_m) $ <eq:161>
$ C_D_b = (0.029 (d_b/d_m)^3)/(sqrt((C_D_f)_b)) $ <eq:162>

$(C_D_0)_"FB"$ is based on the maximum body frontal area $S_m$.
@fig:datcom-notation explains most of the notation pertaining to rocket geometry used in @eq:159 through @eq:162.
Additional explanatory discussion may be found in Sections #ref(<sec:datcom-fin-drag>, supplement: none) and #ref(<sec:datcom-body-drag>, supplement: none), where we shall examine in detail the calculation of $(C_D_0)_F$ and $(C_D_0)_B$, respectively.

#figure(
  image("../../assets/figures-original/fig3-43.png"),
  caption: [Notation used in the Datcom method for computing the drag of simple model rockets at zero angle of attack.
  Note that the variable b as used here refers to the span of a single fin, from root to tip; elsewhere in this chapter it usually refers to the span of a diametrically opposed pair of fins, tip to tip.]
) <fig:datcom-notation>

==== Zero-Lift Drag Coefficient of the Fins <sec:datcom-fin-drag>
The _Datcom_ expression for the drag coefficient of the fins at zero angle of attack is @eq:159, which we repeat here for convenience:
// === page 174 ===
// Figure 43
// Figure 44
// === page 175 ===
#math.equation(block: true, numbering: none)[
  $(C_D_0)_F = 2 (C_f)_F (1 + 2 t/c) (S_F)/(S_m)$
]
where 
/ $t/c$: is the average streamwise thickness ratio of the fins;
/ $(C_f)_F$: is the flat-plate skin-friction coefficient of the fins; 
/ $S_F$: is the total fin planform area; and 
/ $S_m$: is the maximum body frontal, or cross-sectional, area.
In the interest of clarity, certain of these terms are explained in greater detail below: 

For the purpose of these calculations, the planform area of a fin is considered to be the _sum_ of its actual, exposed planform area and the planform area of its _imaginary extension into the body tube_.
@fig:fin-planform-area illustrates the procedure for obtaining this "gross area", denoted by $sigma_F$, for a number of possible fin planforms.
For most fins, $sigma_F$ can be obtained by simply extending the leading and trailing edges until they intersect the body longitudinal axis.
For shapes like that of the Python-2 @handbook-model-rocketry, where the trailing edge intersects the body tube at a very shallow angle, it is better to extend straight lines from the leading and trailing edges of the root chord, parallel to the base, until they intersect the body centerline as shown.
For a rocket with $n$ identical fins, the total fin planform area $S_F$ is equal to $n sigma_F$.

#figure(
  image("../../assets/figures-original/fig3-44.png"),
  caption: [Obtaining the gross planform area of various fin shapes (shapes after G. Harry Stine).]
) <fig:fin-planform-area>

Because $S_F$ is greater than the exposed fin area $S_E$, we expect $(C_D_0)_F$ as given by @eq:159 to be an overestimate
// === page 176 ===
of the true skin-friction drag.
The difference between the overestimated and true values represents an approximation to the interference drag resulting from the juncture of the body and fins.
$C_"DI"$, the interference drag coefficient, is then given by
$ C_"DI" = 2(C_f)_F (1 + 2 t/c) (S_F - S_E)/(S_m) $ <eq:163>
In the _Datcom_ method, therefore, the skin-friction drag of the imaginary fin area within the body tube is taken to be the interference drag at zero angle of attack.
It is apparent from our rather arbitrary means of determining the "hidden" fin area that we cannot expect any great precision in such a determination of $C_"DI"$.
This is the best practical method currently available, however, since $C_"DI"$ is an extremely difficult quantity to evaluate, whether theoretically or experimentally.

The _thickness_ $t$ of the fin can be represented for most purposes by the thickness of the original material from which the fin was constructed.
Painstaking micrometer readings may look scientific, but they cannot improve the accuracy of an approximate method.
The _chord_ $c$ used in these calculations is the average chord of the fin.
For simple planforms, the expression
$ c = (c_"root" + c_"tip")/2 $ <eq:164>
can be used, while for more complicated shapes the determination can be made according to
$ c = (sigma_E)/b $ <eq:165>
// === page 177 ===
where $sigma_E$ denotes the exposed planform area of one fin and $b$ is the fin span, or radial distance from root to tip.

The skin-friction coefficient of the fins, $(C_f)_F$, can be determined from the results of the preceding sections.
@eq:63 may be used if the flow is completely laminar, while @eq:101 applies in cases where transition occurs.
Alternatively, the designer may choose to read the skin-friction coefficient from @fig:skin-friction-coefficient to save the work of making a calculation.
The Reynolds number used in the determination of $(C_f)_F$ is based on the average fin chord: $R_c = (U_(infinity) c)/nu$.
Since the local chord may be considerably larger than this average value at certain locations on the fin, it is possible that transition will occur at lower velocities than predicted on the basis of $R_c$, and that the skin-friction coefficient will be underestimated when using @eq:63 or @eq:101, or @fig:skin-friction-coefficient.
Fortunately, the danger of this is not very great, as the flow over the fins is almost entirely laminar throughout the flight for all but a few model rockets, owing to the extremely high airspeeds and large chords necessary to effect transition on a model rocket fin.
The implications of this problem will be further explored later on.

@eq:159 is valid for fins without separated flow at the leading or trailing edges; hence it is valid only for streamlined fins.
At the time of writing there is no convenient, analytical method for estimating the effects of blunt leading and trailing edges on fin drag.
This, however, is not a serious handicap, since no designer careful enough to apply analytical methods to his work will be inclined to permit a threefold drag increase on his rocket by neglecting the small job of sanding
// === page 178 ===
its fins to the proper shape.

==== Zero-Lift Drag Coefficient of the Body <sec:datcom-body-drag>
The _Datcom_ expression for the drag coefficient of the body at zero angle of attack is
$ (C_D_0)_B = (C_f)_B [ 1 + 60/((ell_b/d_m)^3) + 0.0025 ((ell_b)/(d_m)) ] (S_S)/(S_m) + (0.029 (d_b/d_m)^3)/(sqrt((C_D_f)_B)) $ <eq:166>
where 
/ $(C_"Df")_B$: is given by @eq:161, and is also the first term in @eq:166;
/ $ell_b$: is the total length of the rocket body; 
/ $S_S$: is the total wetted surface area of the body, excluding the base; 
/ $S_m$: is the maximum frontal cross-sectional area of the body; 
/ $d_b$: is the diameter of the base; and 
/ $(C_f)_B$: is the applicable skin-friction coefficient for the body.
Again, a more detailed explanation of these terms may prove useful in cases of practical application.

Strictly speaking, @eq:166 is valid for _bodies of revolution_, a class of geometrical shapes to which most model rockets belong.
The _fineness ratio_ $ell_b/d_m$ for several body configurations is defined in @fig:fineness-ratio-definition.
An excellent approximation to the drag coefficient of an object which is _not_ a body
// === page 179 ===
// Figure 45
// Figure 46
// === page 180 ===
of revolution can, however, be computed by utilizing the _equivalent diameter_ given by
$ d_"equiv." = sqrt("Cross-sectional area"/0.7854) $
Such a procedure might be used, for instance, to determine the drag coefficient of a model rocket with an elliptical cross-section.

#figure(
  image("../../assets/figures-original/fig3-45.png"),
  caption: [Definition of fineness ratio for various bodies of revolution.
  The fineness ratio of the nose is given by $(l_n)/(d_n)$; for the other three shapes the fineness ratio is defined as $(l_b)/(d_m)$.]
) <fig:fineness-ratio-definition>

The _wetted area_ of the body $S_S$ is defined as the total surface area of the body in contact with the surrounding fluid, excluding in the case of a model rocket the area of the blunt base.
Mathematically speaking, if $P(x)$ is the cross-section perimeter of the body at any station $x$ (for this calculation $x$ may be reckoned either forward from the base or aft from the nose),
$ S_S = integral_0^(ell_b) P(x) dif x $ <eq:168>
For a circular, cylindrical body tube $P(x)$ is a constant $P = pi d_m$, and
$ (S_S)_("cyl.") = pi d_m ell_b $ <eq:169>
Since $(S_m)_"cyl." = pi r_m^2 = pi d_m^2/4$, we then have
$ ((S_S)/(S_m))_( "cyl." ) = (pi d_m ell_b) / (pi/4 d_m^2) = 4 (ell_b)/(d_m) $ <eq:170>
In @fig:surface-area-ratio $S_S / S_m$ is plotted as a function of component fineness ratio for the cylinder, as well as for ellipsoidal, conical, and tangent-ogive nose and afterbody shapes.
The following equations may also be used to determine $S_S / S_m$ for a variety of nosecone shapes:
// === page 181 ===
#math.equation(block: true, numbering: _ => "(171a)")[
  $(S_S/S_m)_"ELLIP." = 1 + (2 ell/d_m)/sqrt(1-(d_m^2)/4 ell^2) sin^(-1) sqrt(1-(d_m^2)/(4 ell^2))$
] <eq:171a>
#math.equation(block: true, numbering: _ => "(171b)")[
  $(S_S/S_m)_"ELLIP." approx (1+pi ell/d_m)$ for $ell/d_m >> 1$
] <eq:171b>
#math.equation(block: true, numbering: _ => "(171c)")[
  $(S_S/S_m)_"OGIVE" approx 2.67 ell/d_m$ for $ell/d_m > 1.5$
] <eq:171c>
#math.equation(block: true, numbering: _ => "(171d)")[
  $(S_S/S_m)_"cone" = 2 sqrt(1/4 + (ell/d_m)^2)$
] <eq:171d>
#math.equation(block: true, numbering: _ => "(171e)")[
  $(S_S/S_m)_"cone" approx 2 ell/d_m$ for $(2 ell)/d_m >> 1$
] <eq:171e>
#counter(math.equation).update(171)
#set math.equation(numbering: "(1)")
#figure(
  image("../../assets/figures-original/fig3-46.png"),
  caption: [Ratio of surface area to maximum frontal area $S_s/S_m$ as a function of fineness ratio $l/(d_m)$ for various component shapes.
  The functions for ellipsoids, cones, and ogives are approximate and are terminated at the lower limit of fineness ratio for which they give acceptable accuracy.]
) <fig:surface-area-ratio>

The above shapes, or combinations thereof, may be taken as good approximations to most model rocket nosecone shapes.
The geometrical definitions of these shapes are illustrated in @fig:nose-shapes.
The ellipsoidal nose is constructed by first forming an ellipse (which is done by passing a plane through a cone at some angle less than a right angle to the cone axis, but greater than the half-angle of the cone itself), then dividing the ellipse about its minor axis, and finally revolving the remaining half-ellipse about its semimajor axis.
As geometers know, parabolas and hyperbolas can also be constructed from the intersections of cones and planes; a parabola is formed by passing the plane through the cone at an angle to its axis equal to the cone half-angle, while a hyperbola results if the intersection occurs at a lesser angle.
Paraboloidal and hyperboloidal nosecones can, of course, also be constructed, but they are not as good as ellipsoids because they do not become tangent to the body tube at their bases.
Half the lateral section of a tangent-ogive nosecone is formed by the area bounded by a circle, a diameter of that circle, and a half-chord
// === page 182 ===
// Figure 47
// === page 183 ===
of the circle perpendicular to the diameter.
The familiar tangent ogive nose shape is generated by revolving this section about the chord line.
The cone, simplest of the shapes, is generated by revolving a right triangle about its altitude.
The cone suffers from the same shortcoming as the parabola and hyperbola in that the intersection of the nose with the body tube is not smooth.
Its sharp point, however, gives it favorable drag characteristics in supersonic flight, as we shall see in @sec:transonic-supersonic-drag.

#figure(
  image("../../assets/figures-original/fig3-47.png"),
  caption: [Geometrical definitions of common nose shapes.
  (a): An ellipse is formed by passing a plane through a cone at an angle to the cone axis greater than the cone's half-angle.
  The ellipse is divided along its minor axis and spun about its semimajor axis to form an ellipsoidal nose.
  (b): A parabola is formed by passing a plane through a cone at an angle equal to the half-angle of the cone and is then rotated to produce a paraboloidal nose.
  (c): A hyperbola is formed by passing a plane through a cone at an angle less than the cone half-angle and is rotated to produce a hyperboloidal nose.
  (d): A chord line is passed through a circle; the smaller segment thus formed is bisected by a radial line and the shaded half-segment is revolved about the chord line, forming a tangent ogive nose.
  (e): A right triangle is revolved about its altitude to form a conical nose.]
) <fig:nose-shapes>

When computing the ratio $((S_S)/(S_m))$ for a boattail, account must be taken of the fact that the geometrical solid in whose shape the boattail has been made is _truncated_ by the presence of the blunt base.
For a conical boattail of maximum diameter $d_m$ and base diameter $d_b$, the ratio of surface area to maximum cross-sectional area is given by
#math.equation(block: true, numbering: _ => "(172a)")[
  $ ((S_S)/(S_m) )_"BOATTAIL" = (2(d_m - d_b) ell_r)/(d_m^2) sqrt(1 + ( (d_m - d_b)/(2 ell_r) )^2) $
] <eq:172a>
#math.equation(block: true, numbering: _ => "(172b)")[
  $(S_S/S_m)_"BOATTAIL" approx 2(1-d_b/d_m) ell_r/d_m$ for $(2 ell_r)/(d_m-d_b)>>1$
] <eq:172b>
#counter(math.equation).update(172)
#set math.equation(numbering: "(1)")
@eq:172a and @eq:172b may also be used to approximate $( (S_S)/(S_m) )$ for boattails made in the shape of truncated ellipsoids or ogives, as the exact formulae for these shapes are too complicated to be worth the gain in accuracy over @eq:172a and @eq:172b resulting from their use in practice.

If the body, nose, and boattail (if any) have the same maximum diameter, the overall ratio of surface area to maximum cross-sectional area can be expressed as
$ (S_S)/(S_m) = ((S_S)/(S_m))_("NOSE") + ((S_S)/(S_m))_("CYL") + ((S_s)/(S_m))_("BOATTAIL") $ <eq:173>

// === page 184 ===
The original _Datcom_ method employs the turbulent skin-friction coefficient of the body for $(C_f)_B$ and the turbulent skin-friction coefficient of the fins for $(C_f)_F$ in all its calculations.
This, presumably, is because the _Datcom_ was devised for the purpose of providing drag coefficient predictions for full-scale aircraft and rockets.
The Reynolds numbers of such vehicles are much higher than those commonly encountered in model rocketry.
In the numerical example treated in @sec:datcom-javelin, we shall begin the calculations by assuming completely turbulent flow over the rocket body and see how the estimate of the drag coefficient thus obtained compares with experimental values.

The body friction drag coefficient given in @eq:161, which is also the first term on the right of @eq:166, is of the form
$ (C_D_f)_b = (C_f)_B (1 + a) (S_s)/(S_m) $ <eq:174>
The quantity $a$, which typically has a value of about 0.05, may be thought of as a three-dimensional correction to $C_f$ as discussed in @sec:3d-skin-friction.
The term $0.0025 (ell_b)/(d_m)$, according to the _Datcom_, is the pressure-drag contribution of the body due to the effect of its "thickness", or cross-sectional area.
In the _Datcom_ method, therefore, the pressure drag of a streamlined body is reckoned for the purposes of practical calculation as part of its friction drag.
The second -- i.e., base-drag -- term in @eq:166 requires no further discussion here, as it was presented previously in @sec:base-drag.
// === page 185 ===
=== The Datcom Method Applied to the Javelin Rocket <sec:datcom-javelin>
#set math.equation(numbering: none)
To illustrate the application of the equations presented in the preceding section, I shall perform the zero-lift drag coefficient calculation for a specific model rocket: the Javelin, a kit produced by the Centuri Engineering Company, and the same model for which Mercer has published experimentally-determined information on drag obtained through wind-tunnel tests.
The availability of published data gives us a standard by which to measure the accuracy of the _Datcom_ results.
The Javelin, a simple, single-staged vehicle with a tangent-ogive nose, is shown in @fig:javelin-rocket.

#figure(
  image("../../assets/figures-original/fig3-48.png"),
  caption: [The Javelin rocket, produced in kit form by the Centuri Engineering Company of Phoenix, Arizona, shown with its stock BC-74 nosecone.
  All dimensions are given in centimeters.]
) <fig:javelin-rocket>

I shall begin the calculation by making the following assumptions: 
+ the angle of attack is zero; 
+ the model has no launch lug; 
+ the airspeed is 60 meters/second and $nu = qty("1.495e-5", "m^2/s")$; 
+ the finish is hydraulically smooth at the given velocity; 
+ the flow over the fins is completely laminar; 
+ the flow over the body is completely turbulent; and 
+ the flow does not separate from fins or body, except at the base.
The determination then proceeds as follows: 

Step 1: forebody drag coefficient $(C_D_f)_b$
$ (C_D_f)_b = (C_f)_B [ 1 + 60/((ell_b/d_m)^3) + 0.0025 (ell_b)/(d_m) ] (S_S)/(S_m) $
// === page 186 ===
// Figure 48
// === page 187 ===
Assume $(C_f)_B$ given by @eq:86:
$ (C_f)_B = (C_f)_("turb") = (.074)/((R_ell)^(1/6)) $
Since $ell_b = qty("31.75", "cm") = qty("0.3175", "m")$, the Reynolds number based on body length is given by
$ R_ell = (60 times 0.3175)/(1.495 times 10^(-5)) = 1.27 times 10^6 $
Then the skin-friction coefficient of the body is
$ (C_f)_B = .00445 $
Since $(ell_b)/(d_m) = (31.75)/(1.93) = 16.45$ we obtain
$ [ 1 + 60/((ell_b/d_m)^3) + .0025 (ell_b)/(d_m) ] = 1 + .0135 + .0411 approx 1.055 $
The ratio of wetted area to cross-sectional area is
$ (S_S)/(S_m) = ((S_s)/(S_m))_"cyl" + ((S_S)/(S_m))_"ogive" $
For the cylindrical body we find from @eq:170
$ ((S_S)/(S_m))_"cyl" = 4 ell/(d_m) = (22.61)/(1.93) = 46.9 $
and for the ogival nose @fig:surface-area-ratio or @eq:171c gives
$ ((S_S)/(S_m))_"ogive" = 2.7 ell/(d_m) = 2.7 9.14/1.93 = 12.8 $
So
$ (S_S)/(S_m) = 46.9 + 12.8 = 59.7 $
The forebody drag coefficient is thus
$ (C_D_f)_b = .00445 times 1.055 times 59.7 = 0.279 $
// === page 188 ===
Step 2: base drag coefficient $C_D_b$
$ C_D_b = (0.029 (d_b/d_m)^3)/(sqrt((C_D_f)_b)) $
From Step 1,
$ sqrt((C_D_f)_b) = sqrt(0.279) = 0.528 $
and hence the base drag coefficient is
$ C_D_b = 0.029/0.528 = 0.055 $
Step 3: fin drag coefficient $(C_D_0)_F$
$ (C_D_0)_F = 2 (C_f)_F (1 + 2 t/c) (S_F)/(S_m) $
Assume $(C_f)_F$ given by @eq:63:
$ (C_f)_F = (C_f)_("LAM") = (1.328)/sqrt(R_c) $
The average fin chord is simply
$ c = (3.97+2.07)/2 = qty("3.02", "cm") = qty("0.0302", "m") $
Hence the Reynolds number for the fins is
$ R_c = (60 times .0302)/(1.495 times 10^(-5)) = 1.21 times 10^5 $
which gives
$ (C_f)_F = (1.328)/sqrt(1.21 times 10^5) = .00382 $
Fins made of 3/32\" balsa give $t = qty("0.238", "cm")$, so
$ t/c = (0.238)/(3.02) = 0.079 $
// === page 189 ===
The gross area $sigma_F$ of a single fin can be determined by resolving the Javelin fin into rectangles and right triangles, as shown in @fig:javelin-planform (b); this method simplifies the calculation of $sigma_F$ and, although it results in a slightly larger value than that obtained by the standard method (shown in @fig:javelin-planform (a)), the difference is not very significant.
Following @fig:javelin-planform (b), then, 

Area of region I = $1/2 times 1.90 times 4.19 = qty("3.98", "cm^2")$ 

Area of region II = $2.07 times 4.19 = qty("8.68", "cm^2")$

Area of region III = $3.21 times 0.965 = qty("3.10", "cm^2") $

$ sigma_F = (3.98 + 8.68 + 3.10) unit("cm^2") = qty("15.76", "cm^2")$

Since the Javelin has four fins,
$ S_F = 4 sigma_F approx qty("63", "cm^2") $
The body frontal area is
$ S_m = (pi d_m^2)/4 = (3.14 times 1.93^2)/4 = qty("2.92", "cm^2") $
and hence the fin drag coefficient is
$ (C_D_0)_F = 2 times 0.00382 times 1.158 times 63/2.92 = .190 $

Summing the results of steps 1, 2, and 3, we obtain the total zero-lift drag coefficient of the rocket:
$ (C_D_0)_"Fb" = .279 + .055 + .190 = .524 $

#figure(
  image("../../assets/figures-original/fig3-49.png"),
  caption: [Standard and approximate methods of determining the gross fin planform area of the Javelin rocket.
  The approximate method (b) is preferred to the standard method (a) because it is more conservative; that is, it results in a larger value of $sigma_F$.]
) <fig:javelin-planform>

This value is about 25% greater than the drag coefficient measured by Mercer for the Javelin rocket with a Centuri BG-74 nosecone (see @fig:javelin-nose-drag).
// === page 190 ===
// Figure 49
// === page 191 ===

Now suppose we see what happens if I rescind assumption (f) above and replace it with the more accurate assumption that the flow over the body is partly laminar and partly turbulent, with transition occurring at the critical Reynolds number $R_("crit") = 5 times 10^5$.

Step 1: forebody drag coefficient $(C_D_f)_b$ 

The body skin-friction coefficient will now be given by @eq:101:
$ (C_f)_B = (0.074)/((R_ell)^(1/5)) - B/(R_ell) $
From @eq:100 we find $B = 1735$; since $R_ell = 1.27 times 10^6$,
$ (C_f)_B = .00445 - .00137 = .00308 $
The forebody drag coefficient then becomes
$ (C_D_f)_b = .00308 times 1.055 times 59.7 = .194 $
which is a reduction of 30.5% from its previous value of 0.279, or a reduction in the contribution to the overall drag coefficient by 0.085.
This is due to the fact that, at these Reynolds numbers, the skin-friction coefficient for a laminar boundary layer is considerably lower than that for a turbulent boundary layer.

Step 2: base drag coefficient $C_"Db"$ 

Using the new value of $(C_D_f)_b$, we find the base drag coefficient to be
$ C_"Db" = (0.029)/sqrt(.194) = .066 $
The base drag coefficient is thus _increased_ by 20%, but since
// === page 192 ===
it was a relatively small quantity to begin with the actual increase in drag coefficient due to this percentage increase is only 0.011.

Step 3: fin drag coefficient $(C_D_0)_F$ 

Since $R_C$ is less than the critical Reynolds number, laminar flow will be maintained on the fins.
The fin drag coefficient thus remains unchanged from its previous value of 0.190.

Summing the contributions from Steps 1, 2, and 3 we obtain a new value for the total drag coefficient:
$ (C_(D_0))_("FB") = .194 + .066 + .190 = .450 $

This result is only about 7% greater than Mercer's measured value of 0.42 for the Javelin rocket.
Actually, we have no right to expect any closer agreement with Mercer's data, both because a 7% error is within the measurement uncertainty of the type of equipment used in the wind-tunnel experiments and because the wind-tunnel tests were conducted at a much lower velocity than #qty("60", "m/s"), and hence a much lower Reynolds number than that on which the above calculations were based.
An airspeed of #qty("15", "m/s") is representative of the test velocities produced by the type of wind tunnel used in the Mercer experiments.
Suppose we then rescind assumption (c) above and replace it with the assumption that the airspeed is #qty("15", "m/s").
This gives $R_ell = 3.175 times 10^5$ and $R_C = 3.02 times 10^4$.
Both Reynolds numbers are subcritical, so the flow will remain entirely laminar over both body and fins.
// === page 193 ===

Step 1: forebody drag coefficient $(C_D_f)_b$ 

The body skin-friction coefficient is given by
$ (C_f)_B = (C_f)_"LAM." = (1.328)/(sqrt(31.75 times 10^4)) = .00154 $
so the forebody drag coefficient is
$ (C_D_f)_b = .00154 times 1.055 times 59.7 = .097 $
This represents a decrease of 0.097, or 50%, from the transition-flow value of $(C_D_f)_b$.

Step 2: base drag coefficient $C_"Db"$
$ C_("Db") = (.029)/sqrt(.097) = .093 $
This is an _increase_ of 0.028, or 41% over the transition-flow calculated value.

Step 3: fin drag coefficient $(C_D_0)_F$ 

The fin skin-friction coefficient is
$ (C_f)_F = (1.328)/sqrt(3.02 times 10^4) = .00765 $
Then 
$ (C_D_0)_F = 2 times .00765 times 1.158 times 63/(2.92) = .380 $
This is an increase of .190, or _double_ the value calculated for #qty("60", "m/s").
From these calculations we obtain an overall drag coefficient of
$ (C_D_0)_("FB") = .097 + .093 + .380 = .570 $

// === page 194 ===
This is a substantial disagreement with the experimental result -- almost 36%.
And yet the Mercer data should be closer to this value than to the other two values calculated, according to theory.
Discrepancies of this kind can and often do arise, however, due to the airflow characteristics present in the test sections of many small, subsonic wind tunnels.
Test facilities of this type are prone to have much more _free-stream turbulence_ in the air moving through their test sections than is present in the open atmosphere.
The effect of free-stream turbulence in wind-tunnel testing is to raise the _effective Reynolds number_ of the test; i.e., to make the data look as if the Reynolds number were much higher than it actually is.
One may thus conjecture that, although the Mercer tests may have been conducted at an airspeed closer to 15 than to #qty("60", "m/s"), free-stream turbulence in the wind tunnel made the drag coefficient appear as if the Reynolds number of the test had been closer to that produced by a #qty("60", "m/s") airspeed.
If this _were_ the case it would present model rocketeers with a rather paradoxical advantage, for it would mean that a turbulent, low-speed wind tunnel could produce drag coefficient data applicable to higher-speed model rocket flight in the open air.
The difficulty with such an approach, of course, is that one cannot tell precisely what the effective Reynolds number of a test in a turbulent wind tunnel is, except by comparing the data with the semiempirical predictions of _Datcom_ theory.

At a given Reynolds number, there are two major parameters which can be used to adjust the _Datcom_ prediction of the drag coefficient of a given rocket: the critical Reynolds number
// === page 195 ===
and hence, the quantity $B$) and the decrease in base drag coefficient due to the presence of the fins.
Since there are no data available to relate these effects quantitatively to either rocket geometry or flow conditions, such a process of adjustment must at present be considered pure guesswork.
Variations in critical Reynolds number and base-drag reduction due to the fins could certainly be considered to account for the discrepancy between the prediction of our last calculation above and Mercer's experimental determination, but even if numerical estimates of these quantities are derived which, when used with the _Datcom_ method, give an accurate value of $(C_D_0)_"FB"$ for the Javelin rocket, there is no assurance that their use can be extended to other rocket configurations.
The constant $B$, for example, almost certainly depends upon the individual rocket, so there will always be some error inherent in a general technique like the _Datcom_ method.
It can only be hoped that the variation of $B$ from model to model is small enough so that the error is maintained within acceptable limits for model rocketry work -- say, about 10%.

In conclusion, it would appear that full adaptation of the _Datcom_ method to the practical calculation of model rocket drag coefficients requires research to establish reasonably representative values of $B$ for model rockets of different shapes, and to establish a semiempirical relationship between base drag and fin geometry and location, if this effect is indeed significant.

#set math.equation(numbering: "(1)")

=== General Analysis of the _Datcom_ Method <sec:datcom-general>
// === page 196 ===
==== The General Configuration Rocket (GCR) <sec:gcr>
The preceding section was intended to familiarize the reader with the application of the _Datcom_ method to a particular problem.
In this section the drag coefficient equations will be cast into special forms, particularly applicable to model rockets, which will clarify the relationships between rocket geometry and drag.
This general, nondimensional approach will be utilized to discover the behavior of the drag coefficient and the drag force with respect to changing Reynolds number in Sections #ref(<sec:gcr-cd-re>, supplement: none) and #ref(<sec:gcr-drag-re>, supplement: none).

We begin by listing in general form the _functional dependence_ of the drag coefficients upon the variables of the _Datcom_ equations (Equations #ref(<eq:158>, supplement: none) through #ref(<eq:162>, supplement: none)): 
$ (C_D_f)_b = G_1 (B, R_ell, (ell_b)/(d_m), (S_S)/(S_m)) $ <eq:175>
$ C_D_b = G_2 (B, R_ell, (ell_b)/(d_m), (S_S)/(S_m), (d_b)/(d_m)) $ <eq:176>
$ (C_D_0)_B = G_3 (B, R_ell, (ell_b)/(d_m), (S_S)/(S_m), (d_b)/(d_m)) $ <eq:177>
$ (C_D_0)_F = G_4 (B, R_C, t/c, (S_F)/(S_m)) $ <eq:178>
$ (C_D_0)_("FB") = G_5 (B, R_ell, (ell_b)/(d_m), (S_S)/(S_m), (d_b)/(d_m), R_C, t/c, (S_F)/(S_m)) $ <eq:179>
where the right-hand sides of the equations are read as "$G_1$ of $B$, $R_ell$, $(ell_b)/(d_m)$, $(S_S)/(S_m)$", and so on.
They are simply a form of mathematical shorthand to indicate that the drag coefficients depend on the quantities in parentheses on the right in some (as yet unspecified) fashion.

Theoretically, we could obtain a graphical relationship between any one of the above drag coefficients and one of its
// === page 197 ===
variables by assigning constant values to all the other variables in the function.
As a practical matter, however, this would not be very illuminating, as variables like $S_S/S_m$ and $S_F/S_m$ do not convey any concept of shape and are difficult to visualize.
They can be converted to expressions involving only linear dimensions, though, if we assume specific shapes for the nosecone, fins, main body and boattail (if any) of the rocket.

For this reason, we adopt as the basis for the remainder of the analysis in this section the configuration shown in @fig:gcr-configuration: a rocket consisting of an ogive nosecone, a circular cylindrical body, rectangular fins, and a conical boattail.
This class of vehicles will henceforth be referred to as the General Configuration Rocket (GCR), since by varying its proportions one can obtain reasonable approximations to the shape of many single-staged model rockets.
It should be noted that the fins enter the _Datcom_ equations only through their surface area $S_F$ and the thickness ratio $t/c$; hence no generality is lost by assuming rectangular fins for the GCR.
The shape of the fins is important only in determining the drag and side force due to a _nonzero angle of attack_, whereas the _Datcom_ equations presented here involve only the determination of the zero-lift drag coefficient.
Furthermore, the GCR has no specific size until a numerical value for one of its linear dimensions is specified; the variations depicted in @fig:gcr-configuration could be ten centimeters or one meter in length.
This "nondimensionality" is the most valuable property of the GCR concept.

We can now write for the GCR,
// === page 198 ===
// Figure 50
#figure(
  image("../../assets/figures-original/fig3-50.png"),
  caption: [The General Configuration Rocket (GCR), shown with its nomenclature and three of its possible variations.]
) <fig:gcr-configuration>
// === page 199 ===
$ ((S_S)/(S_m))_"GCR" = ((S_S)/(S_m))_"OGIVE" + ((S_S)/(S_m))_("CYL") + ((S_S)/(S_m))_"BOATTAIL" $ 
The approximate expression for the ogive nose is
$ ((S_S)/(S_m))_"OGIVE" approx 2.7 (ell_N)/(d_m) "for" (ell_N > 1.5) $
and the exact equation for the cylindrical body is
$ ((S_S)/(S_m))_"CYL" = 4 (ell_c)/(d_m) $
For the conical boattail, 
#math.equation(block: true, numbering: _ => "(183a)")[
  $((S_S)/(S_m))_"BOATTAIL" = (2(d_m - d_b) ell_T)/(d_m^2) sqrt(1 + ((d_m - d_b)/(2 ell_T))^2)$
] <eq:183a>
which, for any practical boattail, can be accurately approximated as 
#math.equation(block: true, numbering: _ => "(183b)")[
  $((S_S)/(S_m))_"BOATTAIL" approx 2 (1 - (d_b)/(d_m)) (ell_T)/(d_m)$
] <eq:183b>
#counter(math.equation).update(183)
#set math.equation(numbering: "(1)")
Hence, 
$ ((S_S)/(S_m))_"GCR" = 2.7 (ell_N)/(d_m) + 4 (ell_s)/(d_m) + 2 (1 - (d_b)/(d_m)) (ell_T)/(d_m) $
@eq:175, @eq:176, and @eq:177 can also be written
$ (C_D_f)_b = H_1 (B, R_ell, (d_b)/(d_m), {(ell_b)/(d_m), (ell_N)/(d_m), (ell_S)/(d_m), (ell_T)/(d_m)}) $ <eq:185>
$ C_D_b = H_2 (B, R_ell, (d_b)/(d_m), {(ell_b)/(d_m), (ell_N)/(d_m), (ell_S)/(d_m), (ell_T)/(d_m)}) $ <eq:186>
$ (C_D_0)_B = H_3 (B, R_ell, (d_b)/(d_m), {(ell_b)/(d_m), (ell_N)/(d_m), (ell_S)/(d_m), (ell_T)/(d_m)}) $ <eq:187>
where the letters $H$ again just refer to the fact that the value of the quantity on the left-hand side of each equation depends upon the values of the quantities in parentheses on the right-hand side.
The bracketed expression ${(ell_b)/(d_m), (ell_N)/(d_m), (ell_S)/(d_m), (ell_T)/(d_m)}$ means that only three of the four length-to-diameter ratios may be
// === page 200 ===
chosen to specify the problem, since choosing values for any three determines the value of the fourth.
This follows from the fact that
$ (ell_b)/(d_m) = (ell_N)/(d_m) + (ell_S)/(d_m) + (ell_T)/(d_m) $ <eq:188>

In a similar manner, $S_F / S_m$ may be transformed:
$ S_F = 4 sigma_F = 4 ( c b/2 ) = 2 c b $ <eq:189>
$ (S_F)/(S_m) = (2 c b)/(pi (d_m^2)/4) = (8/pi) (c/(d_m)) (b/(d_m)) $ <eq:190>
Furthermore,
$ R_ell = (U_infinity ell_b)/nu quad "and" quad R_C = (U_infinity c)/nu $ <eq:191>
and $R_C$ can therefore be eliminated by substituting
$ R_C = (c/ell_b) R_ell = (c/d_m)/(ell_b/d_m) R_ell $
Consequently, @eq:178 becomes
$ (C_D_0)_F = H_4 ( B, R_ell, (ell_b)/(d_m), t/c, c/(d_m), b/(d_m) ) $ <eq:193>
The fin-body interference drag coefficient, which is one component of the fin drag coefficient, is given by
$ C_"DI" = 2 (C_f)_F ( 1 + 2 t/c ) (S_F - S_E)/(S_m) $ <eq:194>
For the GCR, it is found that
$ (S_F - S_E)/(S_m) = 4/pi [(c/d_m) (d_b/d_m) + (c/d_m)^2 (d_m/ell_T) (1 - d_b/d_m)] $ <eq:195>
so
$ C_"DI" = H_5 ( B, R_ell, (ell_b)/(d_m), t/c, c/(d_m), b/(d_m), (d_b)/(d_m), (ell_T)/(d_m) ) $ <eq:196>
// === page 201 ===
The total drag coefficient is then seen to exhibit the functional dependence
$ (C_D_0)_("FB") = H_6 (B, R_ell, (d_b)/(d_m), t/c, c/(d_m), b/(d_m), {(ell_b)/(d_m), (ell_N)/(d_m), (ell_S)/(d_m), (ell_T)/(d_m)}) $ <eq:197>

Nine independent, dimensionless variables completely determine the overall drag coefficient and its various constituents, as seen in Equations #ref(<eq:185>, supplement: none), #ref(<eq:186>, supplement: none), #ref(<eq:187>, supplement: none), #ref(<eq:193>, supplement: none), #ref(<eq:196>, supplement: none), and #ref(<eq:197>, supplement: none).
Seven of these are strictly geometrical factors; the remaining two ($B$ and $R_ell$) are related to the interaction of the rocket and the fluid through which it moves.
This set of variables is not unique; for example, since
$ (t/c) (c/d_m) = t/d_m $ <eq:198>
any two of these three quantities may be used to replace $t/c$ and $c/d_m$
Although each drag coefficient is a function of more variables than before (Equations #ref(<eq:175>, supplement: none) through #ref(<eq:179>, supplement: none)), the problem has been simplified because there is a direct and visible relationship between $(C_D_0)_"FB"$ and the pertinent factors of rocket geometry and vehicle-fluid interaction.
The _Datcom_ equations, expressed in terms of these 9 variables for the GCR, are as follows:
$ (C_D_f)_b = [1+60/(ell_b/d_m)^3 + .0025 ell_b/d_m] [2.7 ell_m/d_m + 4 ell_s/d_m + 2(1-d_b/d_m) ell_r/d_m] (C_f)_B $ <eq:199>
$ C_D_b = .029 (d_b/d_m)^3 / sqrt((C_D_f)_b) $ <eq:200>
$ (C_D_0)_F = 16/pi (C_f)_F (c/d_m) (b/d_m) (1+2 t/c) $ <eq:201>
$ C_"DI" = 8/pi (C_f)_F (1+2 t/c)[(c/d_m) (d_b/d_m) + (c/d_m)^2 (d_m/ell_T) (1-d_b/d_m)] $ <eq:202>
// === page 202 ===
where 
#math.equation(block: true, numbering: _ => "203a")[
  $ (C_f)_B = 1.328/sqrt(R_ell) quad (R_ell < R_"crit") $
] <eq:203a>
#math.equation(block: true, numbering: _ => "203b")[
  $ (C_f)_B = 0.074/(R_ell)^(1/5) quad (R_ell >= R_"crit") $
] <eq:203b>
#math.equation(block: true, numbering: _ => "204a")[
  $ (C_f)_F = sqrt(ell_b/c) 1.328/sqrt(R_ell) quad (R_ell < R_"crit") $
] <eq:204a>
#math.equation(block: true, numbering: _ => "204b")[
  $ (C_f)_F = (ell_b/c)^(1/5) 0.074/(R_ell)^(1/5) quad (R_ell >= R_"crit") $
] <eq:204b>
#counter(math.equation).update(204)
#set math.equation(numbering: "(1)")
and the overall zero-lift drag coefficient is given by
$ (C_D_0)_"FB" = (C_D_f)_b + C_D_b + (C_D_0)_F $ <eq:205>

It is now a relatively straightforward matter to produce graphs depicting the behavior of any of the above drag coefficients as one of its parameters is varied.
Some of these relationships will be more useful than others; it does not seem productive, for example, to determine the effect of the nose fineness ratio on the base drag coefficient.
To illustrate such an analysis, we instead consider the far more important relationship between drag coefficient and Reynolds number -- which, for a rocket of given length, translates directly into a relationship between drag coefficient and airspeed.

==== Dependence of the Drag Coefficient on Reynolds Number for the General Configuration Rocket <sec:gcr-cd-re>
The Reynolds number $R_ell$ is itself a function of three variables, $U_(infinity)$, $ell_b$, and $nu$.
If the relationship between drag coefficient and $R_ell$ is known, therefore, this relationship can be used to determine $C_D$ as a function of velocity by assuming numerical values for the 8 other quantities in the _Datcom_
// === page 203 ===
equations:
$ C_D = f(U_infinity) quad (ell_b/nu = "constant") $ <eq:206>
A knowledge of the sfunction is essention for accurate performance calculations.
In particular, an assurance that $C_D$ does not vary greatly over the expected velocity range encountered by a given model in flight is required before a constant $C_D$ can be used in the performance calculations for that model with a high degree of confidence.
To determine teh variation of $C_D$ with $R_ell$ for a particular example of the GCR (denoted GCR-x) the following values were assigned to the 8 variables:
#table(
  columns: 4,
  stroke: none,
  [$d_b/d_m = .8$], [$ell_T/d_m = 3$], [$ell_N/d_m = 3.5$], [$ell_S/d_m = 11.5$],
  [$t/c = .02$], [$c/d_m = 1.75$], [$b/d_m = 5$], [$B = 1735 quad (R_"crit" = num("5e5")$]
)
The overall fineness ratio $ell_b/d_m$ is thus 18, making the GCR_x a fairly slender model. Substituting these values into Equations #ref(<eq:199>, supplement: none) through #ref(<eq:204a>, supplement: none), we obtain
#math.equation(block: true, numbering: none)[
$ cases(
  reverse: #true,
  (C_D_f)_b &= 82.8 (C_f)_B,
  C_D_b &= 0.0149 / sqrt((C_D_f)_b),
) (C_D_f)_b + C_D_b = (C_D_0)_B \
C_"DI" &= 4.25 (C_f)_F \
(C_D_0)_F &= 46.4 (C_f)_F $
]
where
#math.equation(block: true, numbering: none)[
$ (C_f)_B &= 1.328/sqrt(R_ell) quad &(R_ell - (U_infinity ell_b)/nu < num("5e5")) \
  (C_f)_B &= 0.074/(R_ell)^(1/5) - 1735/R_ell quad &(R_ell >= num("5e5")) \
  (C_f)_F &= 4.25/sqrt(R_ell) quad &(R_ell < num("5.14e6")) \
// === page 204 ===
  (C_f)_F &= 0.118/((R_ell)^(1/5)) - (num("17900"))/(R_ell) quad &(R_ell >= num("5.14e6")) $]
and the overall zero-lift drag coefficient is therefore
#math.equation(block: true, numbering: none)[
  $ (C_D_0)_("FB") = 82.8 (C_f)_B + (0.0149)/(sqrt(82.8 (C_f)_B)) + 46.4 (C_f)_F $]

The results obtained for Reynolds numbers between #num("1e4") and #num("1e7") are summarized in @tab:6 and presented graphically in @fig:gcr-drag-vs-reynolds.
The total drag coefficient $(C_D_0)_("FB")$ has a very interesting shape which exhibits three main phases.

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr),
    align: center,
    stroke: none,
    inset: (x: 8pt, y: 3pt),
    table.hline(),
    table.header(
      table.cell(inset: (y: 6pt))[$R_ell$],
      table.cell(inset: (y: 6pt))[$C_(D_b)$],
      table.cell(inset: (y: 6pt))[$(C_(D_0))_B$],
      table.cell(inset: (y: 6pt))[$(C_(D_0))_F$],
      table.cell(inset: (y: 6pt))[$(C_(D_0))_(F B)$],
    ),
    table.hline(stroke: 0.5pt),
    [#num("1e4")], [.014], [1.114], [1.970], [3.080],
    [#num("5e4")], [.021], [.513], [.883], [1.396],
    [#num("7e4")], [.023], [.438], [.748], [1.186],
    [#num("1e5")], [.025], [.373], [.627], [1.000],
    [#num("1.5e5")], [.028], [.312], [.510], [.822],
    [#num("2e5")], [.030], [.276], [.441], [.717],
    [#num("3e5")], [.033], [.233], [.359], [.592],
    [#num("4e5")], [.036], [.210], [.312], [.522],
    [#num("5e5")], [.038], [.194], [.279], [.473],
    [#num("6e5")], [.034], [.223], [.255], [.478],
    [#num("7e5")], [.033], [.242], [.236], [.478],
    [#num("8e5")], [.031], [.257], [.221], [.478],
    [#num("9e5")], [.031], [.266], [.208], [.474],
    [#num("1e6")], [.030], [.272], [.197], [.469],
    [#num("1.25e6")], [.030], [.284], [.176], [.460],
    [#num("1.5e6")], [.029], [.289], [.161], [.450],
    [#num("2e6")], [.029], [.293], [.139], [.432],
    [#num("3e6")], [.029], [.292], [.112], [.404],
    [#num("4e6")], [.029], [.287], [.098], [.385],
    [#num("5e6")], [.030], [.281], [.089], [.370],
    [#num("6e6")], [.030], [.276], [.102], [.378],
    [#num("8e6")], [.031], [.268], [.122], [.390],
    [#num("1e7")], [.031], [.261], [.135], [.396],
    table.hline(),
  ),
  numbering: _ => "6",
  caption: [Drag coefficient of the GCR-x rocket at various Reynolds numbers.]
) <tab:6>

#figure(
  image("../../assets/figures-original/fig3-51.png"),
  caption: [Variation of $(C_(D 0))_(F B)$ with Reynolds number for the GCR-x rocket.
  Also shown are the constituent drag functions $(C_(D 0))_B$ and $(C_(D 0))_F$ and the base drag coefficient $C_(D b)$.
  At Reynolds numbers below $5 times 10^5$ the flow over the entire rocket is laminar.
  Between $5 times 10^5$ and $5 times 10^6$ (region (2) on the graph) transition to turbulent flow occurs partway down the body but the flow over the fins is laminar. Above a Reynolds number of $5 times 10^6$ transition to turbulent flow occurs partway back on the fins as well (region (3) on the graph). 
  Region (2) is referred to as the body transition zone; region (3) is called the fin transition zone.]
) <fig:gcr-drag-vs-reynolds>

At Reynolds numbers less than $num("5e5")$ the flow over the entire rocket is laminar and Phase I behavior of the total drag coefficient is observed.
At small Reynolds numbers, $(C_D_0)_("FB")$ is extremely large, achieving a value of 3.08 for $R_ell = num("1e4")$.
This behavior is expected, as the boundary layer thickens with decreasing Reynolds number and viscous forces play a much greater role in the flow behavior than is the case at higher Reynolds numbers.
For a model rocket of 30 centimeters length, a Reynolds number of $10^4$ corresponds to an airspeed of only about #qty("0.6", "m/s").
A well-designed model rocket does not leave its launcher with a velocity much less than #qty("9", "m/s"), so the behavior of the drag coefficient at such low Reynolds numbers is not of much interest in model rocket flight calculations.

At Reynolds numbers between $5 times 10^5$ and $5 times 10^6$ the rocket is operating in Phase 2 flight.
When the critical Reynolds number $R_ell = 5 times 10^5$ is attained, a region of turbulence begins to grow from the model's base forward.
This is reflected in an increase in the body drag coefficient $(C_(D_0))_B$ with increasing Reynolds number.
Simultaneously, however, there is pure laminar
// === page 205 ===
// (Table 6 data appears here in the original scan; recreated above as a Typst table.)
// === page 206 ===
// Figure 51
// === page 207 ===
flow over the fins, and from @eq:204a it is seen that $(C_D_0)_F$ will _decrease_ with increasing Reynolds number.
The net effect of these two opposing trends is to hold $(C_D_0)_("FB")$ virtually constant in this phase, denoted the _body transition zone_ on the graph of @fig:gcr-drag-vs-reynolds.
$(C_(D_0))_B$ does not increase indefinitely, however, as it too is subject to opposing phenomena.
From $R_ell = 5 times 10^5$ to $R_ell = 2 times 10^6$, the increase in skin-friction drag due to the growing turbulent region on the body is greater than the decrease experienced in both the laminar and turbulent regions due to the inverse variation of $(C_f)_B$ with $R_ell$ (see @eq:203a and @eq:203b); thus $(C_D_0)_B$ increases.
At $R_ell = 2.5 times 10^6$, however, the body is mostly turbulent and the important effect becomes the reduction in $(C_f)_B$ with increasing Reynolds number.
Hence, in the upper range of the body transition zone, both $(C_(D_0))_B$ and $(C_(D_0))_F$ are decreasing, and $(C_D_0)_("FB")$ decreases with them.
Phase 2 is the flight regime of greatest interest to the model rocketeer, as most model rocket flight occurs in this range of Reynolds numbers.
A 30-centimeter-long rocket is in Phase 2 flight whenever its velocity is between about #qtyrange(30, 300, "m/s", per: "/").

At a Reynolds number of $5.14 times 10^6$ , the fins of the GCR-x experience the development of a turbulent boundary layer beginning near the trailing edge and the rocket enters Phase 3 flight.
In this phase the behavior of $(C_(D_0))_F$ is completely analogous to that of $(C_(D_0))_B$ in Phase 2.
If @fig:gcr-drag-vs-reynolds were extended to higher Reynolds numbers, $(C_(D_0))_F$ would be seen to attain a peak and then decrease again.
In essence, the roles of $(C_(D_0))_B$ and $(C_(D_0))_F$ are reversed in Phases 2 and 3 with respect to their
// === page 208 ===
effects on $(C_D_0)_"FB"$.
Phase 3 labeled the _fin transition zone_ in @fig:gcr-drag-vs-reynolds, is rarely attained in model rocket flight, due to limitations on engine power and the reapidly increasing magnitude of the drag _force_ at the velocities required to produce these high Reynolds numbers.
Of course, rockets with very large fin chords, comparable to the rocket length $ell_b$, will attain Phase 3 at comparatively low Reynolds numbers -- but this is an uncommon occurance.
The affects of compressibility generally become noticable in Phase 3, or even in the upper range of Phase 2, so our analysis is not completely valid for these high-velocity regimes.

The base drag coefficient is essentially constant over the entire specturm of Reynolds numbers, attaining its maximum value when $(C_D_0)_B$ attains its minimum value -- which occurs at $R_ell = num("5e5")$.
It is a relatively insignificant contribution to $(C_D_0)_"FB"$ at low Reynolds numbers, but in Phase 2 or Phase 3 flight it repreents about 7% of the total drag coefficient.

Although the curves of @fig:gcr-drag-vs-reynolds were determined from specific values for the _Datcom_ variables, their general behavior will not be altered by changes in the values of these variables.
For example, an increase in $ell_N/d_m$, $ell_s/d_m$, or $ell_r/d_m$, or any combination of these three, while the original values of all the other variables are maintained, will widen the body transition zone, as transition on the fins will now occur at a higher value of $R_ell$ (although $R_"crit"$ remains unchanged).
Furthermore, $(C_D_0)_B$ and $(C_D_0)_"FB"$ will be shifted slightly upwards, while $C_D_b$ will be decreased everywhere.
@fig:gcr-drag-vs-reynolds thus presents the correct _shape_ of the drag coefficient vs. Reynolds number for
// === page 209 ===
any model rocket which can be represented (even approximately) by some variation of the GCR.
This category includes a great many slender ($(ell_b)/(d_m) >= 5$) single-staged model rockets.

To determine the drag coefficient as a function of velocity $U_(infinity)$, it is required to know only the values of $nu$ and $ell_b$.
While $nu$ does vary somewhat with altitude as discussed in @sec:atmospheric-properties, one may reasonably assume a constant value of $nu = qty("1.495e-5", "m^2/s", per: "/")$, giving
$ U_(infinity) = (1.495 times 10^(-5))/(ell_b) R_ell $ <eq:207>
Multiplying the abscissa $R_ell$ of @fig:gcr-drag-vs-reynolds by $(1.495 times 10^(-5))/(L_b)$ converts the Reynolds number axis to a velocity axis, measured in #unit("meter per second").
For a rocket of #qty(30, "cm") length,
#math.equation(block: true, numbering: none)[
  $ U_(infinity) = 4.975 times 10^(-5) R_ell $
]
The body transition zone will then begin at an airspeed of #qty("24.9", "m/s"), and if the rocket has the same geometric proportions as the GCR-x, fin transition begins at #qty(256, "m/s").

In general, obtaining a plot of drag coefficient versus Reynolds number, as in @fig:gcr-drag-vs-reynolds, requires a considerable amount of calculation.
This work cannot be avoided if maximum accuracy is desired, as for theoretical predictions of altitude.
As the following section will show, however, it is possible to choose a single value of the drag coefficient $(C_D_0)_("FB")$ which, if used in performance calculations, yields a good approximation to the "exact" behavior predicted by the _Datcom_ method.
// === page 210 ===
==== Dependence of the Drag Force on Reynolds Number for the General Configuration Rocket <sec:gcr-drag-re> 
The drag force $D$ is expressed in terms of the drag coefficient as 
$ D = 1/2 rho U_(infinity)^2 C_D S_m $ <eq:208>
To eliminate $S_m$ and $U_(infinity)$, we write
#math.equation(block: true, numbering: none)[
  $ S_m = (pi d_m^2)/4 $
]
and
#math.equation(block: true, numbering: none)[
  $ U_(infinity)^2 = (R_ell^2 nu^2)/(ell_b^2) $
]
Then
#math.equation(block: true, numbering: none)[
  $ D = 1/2 rho ((R_ell^2 nu^2)/(ell_b^2)) C_D ((pi d_m^2)/4) $
]
and finally 
$ D = [ ((pi/8) rho nu^2)/((l_b/d_m)^2) ] C_D R_ell^2 $ <eq:209> 

Since $C_D$ is known as a function of $R_ell$ from a plot like that of @fig:gcr-drag-vs-reynolds, compiled from _Datcom_ calculations, it is possible to determine the behavior of the drag force as a function of $R_ell$ using @eq:209.
Assuming $nu = qty("1.495e-5", "m^2/s")$ and $rho = qty("1.225", "kg/m^3")$ (sea-level atmosphere), and $(ell_b)/(d_m) = 18$ as for the GCR-X, we have
$ D = 3.33 times 10^(-13) C_D R_ell^2 $ <eq:210>
for the drag force in newtons.

The column headed $D_e$ in Table 7 summarizes the results
// === page 211 ===
// === page 212 ===
obtained from @eq:210 over the Reynolds number range #numrange("1e4", "1e7").
For Reynolds number up to about #num("1e5"), the drag force is very small compared with either the rocket weight (very few model rockets weigh less than #qty(0.25, "newton") at liftoff) or the thrust levels commonly encountered in model rocket engines.
The drag force is so minute in this flight regime that in the graphical representation of the data shown in @fig:gcr-drag-force, no distinction between values of the drag force predicted by @eq:210 and by the assumption of a constant $C_D$ can be seen.

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    align: center,
    stroke: none,
    inset: (x: 8pt, y: 3pt),
    table.hline(),
    table.header(
      table.cell(inset: (y: 6pt))[$R$],
      table.cell(inset: (y: 6pt))[$D_e (N)$],
      table.cell(inset: (y: 6pt))[$D_a (N)$],
      table.cell(inset: (y: 6pt))[Percent error]
    ),
    table.hline(stroke: 0.5pt),
    [#num("1e4")], [#num("1.03e-4")], [#num("1.57e-5")], [-84.6],
    [#num("5e4")], [#num("1.16e-3")], [#num("3.94e-4")], [-66.2],
    [#num("7e4")], [#num("1.94e-3")], [#num("7.70e-4")], [-60.1],
    [#num("1e5")], [#num("3.33e-3")], [#num("1.57e-3")], [-52.6],
    [#num("1.5e5")], [#num("6.18e-3")], [#num("3.53e-3")], [-42.7],
    [#num("2e5")], [#num("9.55e-3")], [#num("6.31e-3")], [-33.9],
    [#num("3e5")], [#num("1.77e-2")], [#num("1.42e-2")], [-20.0],
    [#num("4e5")], [#num("2.77e-2")], [#num("2.51e-2")], [-9.4],
    [#num("5e5")], [#num("3.94e-2")], [#num("3.94e-2")], [0.0],
    [#num("6e5")], [#num("5.74e-2")], [#num("5.65e-2")], [-1.5],
    [#num("7e5")], [#num("7.80e-2")], [#num("7.70e-2")], [-1.1],
    [#num("8e5")], [#num("1.02e-1")], [#num("1.01e-1")], [-1.3],
    [#num("9e5")], [#num("1.28e-1")], [#num("1.27e-1")], [-0.2],
    [#num("1e6")], [#num("1.56e-1")], [#num("1.57e-1")], [0.9],
    [#num("1.25e6")], [#num("2.39e-1")], [#num("2.46e-1")], [2.9],
    [#num("1.5e6")], [#num("3.39e-1")], [#num("3.53e-1")], [4.2],
    [#num("1.75e6")], [#num("4.50e-1")], [#num("4.82e-1")], [7.0],
    [#num("2e6")], [#num("5.82e-1")], [#num("6.31e-1")], [8.4],
    [#num("2.2e6")], [#num("6.89e-1")], [#num("7.63e-1")], [10.8],
    [#num("2.4e6")], [#num("8.05e-1")], [#num("9.09e-1")], [12.4],
    [#num("3e6")], [1.21], [1.42], [17.3],
    [#num("4e6")], [2.05], [2.51], [22.8],
    [#num("5e6")], [3.07], [3.94], [28.0],
    [#num("6e6")], [4.45], [5.65], [27.1],
    [#num("8e6")], [8.31], [10.1], [21.0],
    [#num("1e7")], [13.2], [15.7], [19.6],
    table.hline(),
  ),
  numbering: _ => "7",
  caption: [Comparison of the "exact" drag force in newtons on the GCR-X rocket, calculated using the variable drag coefficient obtained from the Datcom equations, with the approximate drag force calculated on the assumption of $(C_(D 0))_(F B) = 0.473$ at various Reynolds numbers.]
) <tab:7>

#figure(
  image("../../assets/figures-original/fig3-52.png"),
  caption: [Variation of drag force in newtons with Reynolds number for the GCR-X rocket.
  $D_e$ is the "exact" drag obtained using the variable drag coefficient computed by the Datcom method; $D_a$ is the approximate drag obtained by taking $(C_(D 0))_(F B)$ as 0.473.]
) <fig:gcr-drag-force>

The reason for this behavior is that, although $(C_D_0)_"FB"$ is very large for values of $R_ell$ less than $10^5$, the quadratic dependence of the drag forces on the Reynolds number drives $D$ downwards as $R_ell$ decreases.
Since the laminar skin-friction coefficient is inversely proportional to the _square root_ of $R_ell$, $(C_D_0)_"FB"$ cannot increase rapidly enough to offset this effect.

As the Reynolds number increases into the body transition zone, the drag force climbs rapidly, experiencing a tenfold increase between $R_ell = num("6e5")$ and $R_ell = num("2e6")$.
Plotted along with the "exact" function $D_e$ in @fig:gcr-drag-force is an _approximating function_ for the drag $D_a$, derived from @eq:210 by assuming the drag coefficient to be _constant_ over the entire Reynolds number range. The value I have elected to choose for this constant is the value of $(C_D_0)_"FB"$ at the initiation of Phase 2 flight, or $R_ell = num("5e5")$.
From @tab:6 we read this as $(C_D_0)_"FB"$, so
// === page 213 ===
// Figure 52
// === page 214 ===
$ D = 1.58 times 10^(-13) R_ell^2 $ <eq:211>
gives the approximate drag force in newtons.

From inspection of @tab:7, it may be seen that this function approximates $D_e$ quite closely over the range of Reynolds numbers of interest in model rocket flight, deviating less than 10% from the exact function for Reynolds numbers between $4 times 10^5$ and $2.2 times 10^6$.
Furthermore, although the percentage error is large below $R_ell = 4 times 10^5$ (as $C_D$ attains large values in the exact calculation), the absolute magnitude of the drag force is so small that these deviations are insignificant in the calculation of model rocket performance.
It is not necessary to know whether the drag force is 1/1000 of a newton or 2/1000 of a newton when the thrust and weight of the vehicle are both three or four orders of magnitude greater than these values.

At higher Reynolds numbers -- that is, $R_ell$ greater than $5 times 10^5$ -- $D_a$ represents a good approximation to the actual drag force because, as we saw in @fig:gcr-drag-vs-reynolds, the drag coefficient is very nearly constant in the body transition zone.
The value of $(C_D_0)_"FB"$ at $R_ell = 5 times 10^5$ was chosen as the approximate, constant $C_D$ for the calculations on which @tab:7 and @fig:gcr-drag-force are based for two major reasons: first, because $R_ell = 5 times 10^5$ may be considered to represent the onset of body transition for all model rockets, regardless of configuration; and second, because the exact magnitude of the drag is obtainable from this value of $C_D$ to within 10% up to Reynolds numbers in the neighborhood of $2.2 times 10^6$, very nearly the practical limit of $R_ell$
// === page 215 ===
encountered during the flight of small- to moderate-sized model rockets.

This result can be stated in the form of a semiempirical rule: for single-staged model rockets not expected to exceed a Reynolds number of about $3 times 10^6$ in flight, the assumption of a constant $C_D$ with a value equal to that attained at $R_l = 5 times 10^5$ yields acceptable estimates of performance when used in closed-form altitude calculations requiring the assumption of a constant $C_D$.

The Reynolds number axis of @fig:gcr-drag-force, like that of @fig:gcr-drag-vs-reynolds, can be converted to a velocity axis by applying the coordinate transformation given in @eq:207.

== Model Rocket Drag at Transonic and Supersonic Speeds <sec:transonic-supersonic-drag>
=== Limits on the Applicability of Incompressible Analysis <sec:incompressible-limits>
As stated in @sec:density, the results of the analyses and semiempirical treatments contained in the first six sections of this chapter can be assumed accurate on an _a priori_ basis only if the compression of the atmosphere due to the airspeed of the model is relatively slight.
The reader may also recall from this discussion that the analytical criterion of "sufficiently slight" compression corresponds to a _Mach number_ $M$ of less than 0.316, where
$ M = U_(infinity)/c $ <eq:212>
and $c$ is the speed with which sound waves travel through the air: the so-called "speed of sound".

Strictly speaking, the Mach number associated with a given
// === page 216 ===
airspeed varies with atmospheric conditions, since $c$ itself varies with atmospheric composition and temperature.
In this connection you may again wish to consult @fig:atm-sound-speed, which shows the variation of sound speed with altitude for the United States standard atmosphere.
The dependence of $c$ upon local temperature is given by
$ c = c_("std") sqrt(T/T_("std")) $ <eq:213>
where $T_("std")$ is the standard atmospheric temperature at the altitude in question and $T$ is the actual temperature at that altitude at the time in question, and where the temperatures must be measured on one of the absolute scales, Rankine or Kelvin.
It is found from @fig:atm-sound-speed and @eq:213, however, that the speed of sound varies only slightly -- a few percent at most -- over the range of temperatures for which it is practical to launch model rockets and over the range of altitudes present-day models can achieve.
It is therefore reasonable to assume that $c$ remains constant at its sea-level standard value of about #qty(340, "m/s") for all calculations of interest to model rocketeers.
The maximum airspeed at which the results obtained from incompressible-flow theory can be considered analytically valid is therefore approximately #qty(107, "m/s").

Above this speed the influence of compressibility on the flow about the rocket makes its presence known through a number of phenomena.
The air in the vicinity of the stagnation points at the tip of the nose and the leading edges of the fins, as well as the air within the boundary layer, increases noticeably in density.
The boundary layer thickens and its velocity
// === page 217 ===
profile becomes altered.
The fins behave as if their aspect ratio were lower than that which is geometrically the case.
A precise, analytical description of the effects of each of these phenomena upon the overall drag of the model would fill a book by itself.
It is not our purpose to present such a treatment here, as the mathematics involved are quite a bit more complex than those by which we have been able to treat incompressible flow.
Furthermore, only a small portion of the vast literature that has grown up around the study of compressible fluid flow is of appreciable interest to model rocketeers.
What _is_ of interest to us as designers of high-performance model rockets is the experimentally-observed fact that _the overall drag coefficient of a finned body of revolution, such as a model rocket, does not exhibit any appreciable deviation from the value predicted by incompressible flow theory at Mach numbers below 0.9_.
It is Nature's gift to the designer that the various compressibility phenomena interact in such a manner as to make this true.
Although the results of incompressible flow theory are not _analytically valid_ above $M = 0.316$, therefore, they are _numerically accurate_ up to $M = 0.9$ and may thus be used without modification in closed-form performance calculations.
In short, the effects of compressibility on the drag coefficient of a model rocket are negligible at airspeeds up to approximately #qty(306, "m/s").

=== Drag Divergence <sec:drag-divergence>
As a model rocket approaches "Mach one" -- the speed of sound -- regions form near the nose tip and the fin leading
// === page 218 ===
edges in which the air is highly compressed over a relatively short distance.
In a similar manner, regions form near the fin trailing edges and the body tube base in which the air expands again to fill the partial void left by the rocket's passage.
This behavior is associated with the fact that the speed of sound in a fluid is _the speed with which fluid elements can transmit information to one another_.
As a body travelling through the fluid approaches the sonic velocity the fluid directly in front of it cannot "inform" the fluid further upstream that the body is approaching in time for the upstream fluid elements to move smoothly aside to let the body pass (as they do in subsonic flight).
The upstream elements therefore "pile up" on one another and become crushed, or compressed, against the nose tip and the fin leading edges of a model rocket entering the transonic flight regime.
Once the model has passed by, the compressed fluid elements endeavor to return to their original volume, thus undergoing a rapid expansion.

At a Mach number of 1.0 the region of compression at the nose becomes a thin surface normal to the longitudinal axis of the rocket, called a _normal shock_.
As $M$ increases above 1.0 the compression region becomes conical, with the cone half-angle decreasing as the Mach number increases: a three-dimensional _oblique shock_.
The surface bounded by the oblique shock trailing from the nose of a supersonically-flying body of revolution is called the _Mach cone_; in cases of horizontally-flying airplanes this cone may intersect the ground, causing observers to hear the so-called _sonic boom_.
In addition, any sound produced by the body itself can only be heard within the Mach cone; to an
// === page 219 ===
observer outside the cone the vehicle appears to be flying in perfect silence.
For this reason a supersonic airplane can only be heard after it has already passed overhead, and an observer on the ground must "lead" the sound (i.e., look ahead of it) in order to see the aircraft.
The expansion of the atmosphere into the region behind a model rocket in supersonic flight occurs with a very rapid decrease in density, exhibiting a characteristic flow pattern known as the _Prandtl-Meyer expansion fan_.

Now the importance of these phenomena to model rocket drag is that the air which passes through the shock and expansion pattern surrounding the model is _not_ returned completely to its original state once the rocket has gone by.
The shock/expansion system causes a certain amount of _momentum_ to be transferred from the model to the airstream over and above the quantity that would be transferred under subsonic conditions.
The drag coefficient of a model rocket in transonic and supersonic flight is therefore _greater_ than its subsonic drag coefficient.
Typically, $C_D$ increases rapidly as Mach 1.0 is approached, reaches a peak at slightly above the sonic velocity, and declines again toward a value that is somewhat greater than the subsonic drag coefficient as the Mach number increases toward 2.0.
The rapid increase experienced in the transonic regime, between $M = 0.9$ and the Mach number at which the peak $C_D$ occurs, is called _drag divergence_.
The existence of drag divergence is one reason that it was common to call Mach one "the sound barrier" before the rocket-powered Bell X-1 airplane first exceeded it in 1947, and for some years thereafter.
Drag divergence also
// === page 220 ===
means that it is extremely difficult for small vehicles of limited total impulse, such as model rockets, to exceed Mach one.
Only our very highest-performance designs can accomplish this feat, and then only when powered by the highest-thrust model rocket engines available -- types B14, F67, F100, and so on -- and even then resort must often be had to multiple staging.

=== Semiempirical Determination of Transonic and Supersonic Drag Coefficients <sec:semiempirical-transonic>
The mathematical complexity associated with the analysis of compressible fluid flow about a finned body of revolution is too great to permit the practical calculation of transonic and supersonic drag coefficients directly from first principles.
As was the case for subsonic flight, we must have recourse to semiempirical formulae based on experimental data in order to obtain values of $C_D$ for use in model rocket performance calculations.
Hoerner @fluid-dynamic-drag presents drag coefficient data for a number of small fin-body combinations tested at transonic and supersonic velocities.
As shown in @fig:transonic-drag (a), the test results fall into two distinct categories: one containing rockets having sharp (ogival or conical) noses, and one comprised of models having rounded nose shapes.
For the sharp-nosed rockets the drag coefficient $C_D$ rises to 1.7 times its subsonic value (denoted $C_(D s)$) at $M = 1.05$ and then declines again to about $1.27 C_(D s)$ as $M$ approaches 2.0.
The round-nosed configuration is more severely affected by compressibility: its $C_D$ peaks at $2.17 C_(D S)$ at $M = 1.2$ and falls back only as far as $2.0 C_(D s)$ for $M$ approaching
// === page 221 ===
// Figure 53
// === page 222 ===
2.0.
The difference in behavior between the two configuration classes is due to a fundamental difference in nature between the shock associated with a sharp nose and the shock generated by a rounded nose.
The oblique shock produced by a sharp nose in supersonic flight is an _attached_ shock; i.e., the shock appears to be shed directly from the point of the nose like a cone suspended on a pencil point.
The shock due to a rounded nose, on the other hand, it itself rounded at its forward extremity and is _detached_: it "stands off" slightly ahead of the front surface of the nose itself.
@fig:shock-patterns illustrates the difference in structure between the two shock patterns, and also the shock/expansion pattern observed in the neighborhood of the base of a blunt-based body of revolution.
As there is appreciably greater momentum transfer associated with the detached than with the attached shock, the rounded-nose configurations have higher drag coefficients at transonic and supersonic velocities.

#figure(
  image("../../assets/figures-original/fig3-53.png"),
  caption: [Variation of drag coefficient with Mach number for finned bodies of revolution.
  (a): Experimentally determined behavior of the drag coefficient of the rocket pictured, using both ogive and half-round noses.
  (b): Analytical functions described in equations (214) and (215) that approximate the experimental behavior to within 10%.]
) <fig:transonic-drag>

#figure(
  image("../../assets/figures-original/fig3-54.png"),
  caption: [Shock and expansion patterns about sharp-nosed and blunt-nosed bodies of revolution.
  Solid lines indicate shocks and compression waves; dotted lines indicate expansion waves or fans; wavy lines delineate the wakes of the bodies.
  The conical nose produces an attached shock (a) which results in a lower drag than the detached shock (b) formed in front of the rounded nose.]
) <fig:shock-patterns>

It is mathematically possible to construct formulae for the drag coefficients which will represent the curves of @fig:transonic-drag (a) to a very high order of precision.
Such a procedure is not really worth the trouble, though, since the data presented in @fig:transonic-drag (a) are only approximate (in fact, the curves above Mach 1.5 are based on extrapolation) and their applicability to a wide range of model rocket configurations has not been established.
If one takes the liberty of initially assuming a high-performance rocket configuration (which in itself is justified by the fact that only the highest-performance model rockets are in fact capable of exceeding Mach one), however, it should prove possible
// === page 223 ===
// Figure 54
// === page 224 ===
to construct approximating functions that are relatively simple, yet will represent $C_D$ with reasonable accuracy over the Mach number range of interest to the hobbyist.

One possible choice for such a function assumes a rise in $C_D$ given by a power function in Mach number, followed by a decline given by an exponential in Mach number.
Such a representation is referred to as _piecewise smooth_, since the graph obtained from such a set of formulae is a smooth curve everywhere except at the point at which the first formula leaves off and the second begins -- where there is a sharp "peak".
It will be found that a reasonably accurate set of approximating functions of this type for sharp-nosed vehicles is given by
#math.equation(block: true, numbering: _ => "(214a)")[
  $ C_D/C_D_S = 1.0 + 35.5 (M - 0.9)^2 quad (0.9 <= M <= 1.05) $
] <eq:214a>
#math.equation(block: true, numbering: _ => "(214b)")[
$ C_D/C_D_S = 1.27 + 0.53 e^(-5.2(M-1.05)) quad (1.05 <= M <= 2.0) $
] <eq:214b>
and that a similar set for round-nosed rockets may be written
#math.equation(block: true, numbering: _ => "(215a)")[
$ C_D/C_D_S = 1.0 + 4.88 (M - 0.9)^(1.1) quad (0.9 <= M <= 1.2) $
] <eq:215a>
#math.equation(block: true, numbering: _ => "(215b)")[
$ C_D/C_D_S = 2.0 + 0.3 e^(-5.75(M-1.2)) quad (1.2 <= M <= 2.0) $
] <eq:215b>
#counter(math.equation).update(215)
These approximating functions are displayed in @fig:transonic-drag (b) and compared with the experimental data curves in Table 8.
Inspection of Table 8 reveals that even these relatively simple functions predict $C_D$ values within 10% of those determined by experiment over the Mach number range 0.9 through 2.0.

#figure(
  grid(
    columns: (1fr),
    column-gutter: 16pt,
    row-gutter: 8pt,
    align(center)[*Ogive Nose*],
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: none,
      inset: (x: 8pt, y: 3pt),
      table.hline(),
      table.header(
        table.cell(inset: (y: 12pt))[$M$],
        table.cell(inset: (y: 12pt))[$[C_D/C_D_s]_e$],
        table.cell(inset: (y: 12pt))[$[C_D/C_D_s]_e$],
        table.cell(inset: (y: 12pt))[Percent error]
      ),
      table.hline(stroke: 0.5pt),
      [0.90], [1.00], [1.000], [ 0.00],
      [0.95], [1.17], [1.089], [-6.92],
      [1.00], [1.43], [1.355], [-5.25],
      [1.05], [1.70], [1.800], [ 5.56],
      [1.10], [1.67], [1.680], [ 0.60],
      [1.20], [1.57], [1.513], [-3.63],
      [1.40], [1.40], [1.356], [-3.14],
      [1.60], [1.30], [1.300], [ 0.00],
      [1.80], [1.27], [1.281], [ 0.84],
      [2.00], [1.27], [1.274], [ 0.31],
      table.hline()
    ),
    v(1cm),
    align(center)[*Half-Round Nose*],
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: none,
      inset: (x: 8pt, y: 3pt),
      table.hline(),
      table.header(
        table.cell(inset: (y: 12pt))[$M$],
        table.cell(inset: (y: 12pt))[$[C_D/C_D_s]_e$],
        table.cell(inset: (y: 12pt))[$[C_D/C_D_s]_e$],
        table.cell(inset: (y: 12pt))[Percent error]
      ),
      table.hline(stroke: 0.5pt),
      [0.90], [1.00], [1.000], [ 0.00],
      [0.95], [1.17], [1.182], [ 1.03],
      [1.00], [1.43], [1.389], [-2.86],
      [1.05], [1.76], [1.610], [-8.50],
      [1.10], [2.00], [1.830], [-8.50],
      [1.20], [2.17], [2.300], [6.00],
      [1.40], [2.10], [2.095], [-0.24],
      [1.60], [2.03], [2.030], [ 0.00],
      [1.80], [2.00], [2.010], [ 0.48],
      [2.00], [2.00], [2.003], [ 0.15],
      table.hline()
    ),
  ),
  numbering: _ => "8",
  caption: [Comparison of the analytical drag divergence functions $C_D/C_("DS")$ (subscript $a$) given in equations (214) and (215) with the experimentally observed drag divergence functions $C_D/C_("DS")$ (subscript $e$) for rockets with ogive and half-round noses at Mach numbers between 0.9 and 2.0.]
) <tab:8>

I cannot emphasize strongly enough, however, that you should _not_ regard @eq:214a through @eq:215b as having any valid basis in mathematical physics, or as having a precision anywhere
// === page 225 ===
// === page 226 ===
near that of the _Datcom_ equations for subsonic flight.
The tenuous nature of the connection between the experimental data and the actual flight of model rockets, and the extent to which I have extrapolated the data curves, is such that the best that can be said of @eq:214a through @eq:215b is that they represent _reasonable suggestions_ of the behavior of model rocket drag coefficients at transonic and supersonic speeds.
They are to be used with the understanding that they are tentative and with the provision that they are acceptable for use only until better approximations are available.
At present, however, they may be considered accurate enough for design study and altitude prediction work.

Finally, the reader should realize that the behavior of the drag coefficient at these high velocities presents us with a fundamental analytical difficulty in carrying out performance calculations.
Since $C_D$ in this flight regime is a strongly-varying function of Mach number, and hence of velocity, a constant, average value of $C_D$ _cannot_ be used in computing altitude performance.
This precludes the use of any of the closed-form, analytical altitude-performance equations presented in Chapter 4 and makes the use of computerized interval methods essential in calculating the performance of any model rocket that is expected to enter the transonic and/or supersonic range of velocities at any time during its flight.

== Experimental Determination of Drag Coefficients <sec:experimental-drag>
All the material presented thus far in this chapter has dealt with the theoretical or semiempirical prediction of
// === page 227 ===
model rocket drag coefficients
In order to determine the accuracy of the drag coefficient values obtained from such predictive calculations it is necessary to compare them to results obtained by experimental measurement.
In addition, there exist designs whose shape is too complicated to permit the use of any of the analytical methods discussed in the preceding sections (the reader will recall, for instance, that even the presence of a mere launch lug forced us to use a tentative and highly speculative semiempirical rule to account for its effect).
We therefore conclude this chapter with a brief discussion of three basic experimental techniques which may be used to determine the drag coefficient of any model rocket.

=== Wind Tunnel and Balance System <sec:wind-tunnel>
The most common experimental technique presently in use for determining drag coefficients, whether of model rockets or any other objects, is the wind-tunnel test.
I will assume that readers of this volume already have some knowledge of wind tunnels, balances, and testing procedure; for the topic of wind-tunnel testing itself is a very broad one and would require far too lengthy a discussion for us to include it here.
Those interested may find explanations of the various types of tunnels and balance systems, as well as information of use in designing and building wind tunnels, in an excellent book on the subject called _Wind Tunnel Testing_, by Alan Pope, published by John Wiley and Sons of New York in several editions over the last twenty years.

#figure(
  image("../../assets/figures-original/plate3-6.png"),
  kind: "plate",
  supplement: [Plate],
  caption: [A small wind tunnel that can be used to measure the drag coefficient of a model rocket.]
) <plate:wind-tunnel>

@plate:wind-tunnel shows a small wind tunnel and balance system capable of testing model rockets at airspeeds up to about 
// === page 228 ===
// Plate 6
// === page 229 ===
#qty(19, "m/s").
The particular version illustrated is a return-flow tunnel of the "single-return" variety, in which the air circulates clockwise through the closed, doughnut-like duct system.
It can be constructed, complete with variable-speed drive, for several hundred dollars and represents a type that can be afforded by some of the larger model rocket clubs and NAR Sections.
A somewhat similar (but larger) design was used by Mark Mercer for his drag experiments.
One can also construct much simpler, "open-circuit" tunnels in which the air is drawn through an intake, passes through the test section, and is expelled through a "diffuser", or exhaust.
In designing any wind tunnel the greatest care must be exercised to prevent, insofar as is possible, turbulence in the airstream which passes through the test section.
If too much turbulence is present the tunnel airflow will not accurately duplicate the conditions existing in free flight and the experimental results may not be accurate.
Most wind tunnels thus far constructed by model rocketeers are in fact known to suffer from this problem.
Another difficulty encountered by hobbyists attempting to design home-built wind tunnels involves velocity: the test-section airspeed must be high enough to provide reasonably good dynamic similarity (a Reynolds number not too different from those encountered in flight); yet, for a given test section cross-sectional area, the motor power required increases approximately as the _cube_ of the desired airspeed!
In short, the design and construction of a wind tunnel that can provide high-quality drag data is not a project to be taken lightly: it will make considerable demands on a modeler's time, skill, and finances.

// === page 230 ===
Assuming that one _has_ a wind tunnel and balance system (or access to one, as in a university), however, the drag coefficient of any model mounted on the balance can be determined by reading the drag directly from the balance indicator.
The drag reading obtained must be corrected for _tare_ (the drag of the balance support arm itself), aerodynamic interference between the model and the balance arm, and the effect of the test section walls on the airflow pattern about the model.
Pope's text outlines the techniques for accomplishing these corrections with a high degree of precision (this is, however, a rather tedious task and many hobbyists prefer simply to subtract the tare drag from the total drag reading, a procedure which still permits determinations of $C_D$ to within 5% in most cases).
The drag coefficient is then found from the corrected drag using the equation
$ C_D = D/(1/2 rho S_m U^2) $ <eq:216>
where the test-section velocity $U$ is that which has been measured on the velocity-indicating manometer.
In a good wind tunnel the airspeed can be varied from zero to the maximum of which the tunnel is capable at will, by using an electrical or hydraulic control.

The performance calculations of Chapter 4 use a _drag parameter_ $k$, given by
$ k = 1/2 rho S_m C_D $ <eq:217>
rather than the drag coefficient $C_D$ explicitly, in determining velocity and altitude.
This drag parameter can be determined
// === page 231 ===
from the corrected drag as just
$ k = D/(U^2) $ <eq:218>

=== Vertical Wind Tunnel <sec:vertical-wind-tunnel>
A number of prominent modelers have suggested the construction of a _vertical_ wind tunnel; that is, one in which the test-section airstream travels _directly upward_.
Such a design has the advantage of not requiring a balance system, since the airspeed can be adjusted until the model is suspended motionless in the center of the test section.
The drag is then just equal in magnitude to the model's weight:
$ D = k U^2 = m g $ <eq:219>
so
$ k = (m g)/(U^2) $ <eq:220>
where $m$ is the mass of the model and $g$ is the acceleration of gravity.
In MKS (meter-kilogram-second) units, $m$ is given in kilograms and $g$ is #qty(9.8, "m/s^2").
The drag coefficient, if desired, can be extracted from the drag parameter using the relation
$ C_D = k/(1/2 rho S_m) $ <eeq:221>
The vertical tunnel concept does have some drawbacks.
For one thing, fairly high velocities -- #qtyrange(50, 75, "m/s") or even more -- will be required to make the drag of a high-performance model rocket equal its weight.
The required velocity can be
// === page 232 ===
reduced by constructing a light test model and leaving out the engine, but the vertical wind tunnel will still need quite a lot more power than a standard, horizontal design using a balance.
There may also be problems in maintaining the model's position within the test section, and the testing technique can only determine drag at a zero angle of attack.

=== Vertical Drop Test <sec:vertical-drop-test>
It has also been noted that the drag parameter of a model can be determined without a wind tunnel, by measuring the _time_ taken by the model to _fall_ a specified distance when released from rest in a nose-down attitude.
The relationship between the time of fall and the drag parameter can be determined by solving the differential equation of the rocket's motion, which is just Newton's second law for an object of constant mass:
$ arrow(F) = m arrow(a) = m (dif arrow(U))/(dif t) $ <eq:222>
Where $arrow(F)$ is the vector sum of the forces acting on the object and $arrow(a)$ is its acceleration.
If we adopt the convention that force, acceleration, velocity, and displacement are all to be considered positive downward we have for the falling rocket
$ m (dif U)/(dif t) = m g - k U^2 $ <eq:223>
This equation can be solved for _time_ as a function of _velocity_:
$ t = integral_0^U (dif U)/(g - k/m U^2) $ <eq:224>
The integral on the right-hand side of @eq:224 is known to have the form
// === page 233 ===
$ t = sqrt(m/(g k)) tanh^(-1) [ U sqrt(k/(m g))] $ <eq:225>
from which, by algebraic manipulation and the use of inverse functions, we obtain
$ U = sqrt((m g)/k) tanh [t sqrt((g k)/m)] $ <eq:226>
Since the hyperbolic tangent function approaches 1.0 for time approaching infinity, the _terminal velocity_ of the falling model is seen to be $sqrt((m g)/k)$ — the same velocity required to suspend the model motionless in the vertical wind tunnel.

Letting the _displacement_, or distance fallen, be denoted by $x$, and recognizing that $U = (dif x)/(dif t)$, we have
#math.equation(block: true, numbering: none)[
  $ (dif U)/(dif t) = (dif U)/(dif x) (dif x)/(dif t) = U (dif U)/(dif x) $
]
Then @eq:223 can be written
$ m U (dif U)/(dif x) = m g - k U^2 $ <eq:227>
and solved for $x$ as follows:
$ x = integral_0^U (U dif U)/(g - k/m U^2) $ <eq:228>
performing the integration, we have
$ x = -m / (2k) ln [ 1 - (k / (m g)) U^2 ] $ <eq:229>
Note that the argument of the natural logarithm function is always less than one; hence the logarithm itself is a negative number and $x$ is a positive quantity, as it should be, indicating downward displacement.
By substituting the right-hand side of @eq:226 for $U$ we obtain the desired functional relationship
// === page 234 ===
between displacement and time:
$ x = -m/(2k) ln [ 1 - tanh^2 ( t sqrt((g k)/m) ) ] $ <eq:230>
Again, $x$ will be found positive for all positive values of $t$.

@eq:230 can be used in conjunction with computerized calculation methods to compile graphs which display time as a function of the variable ($k/m$) for various values of the "drop distance" $x$.
One such "drop chart" is shown in @fig:drop-chart.
Inspection of the chart reveals that a fairly sizeable drop distance is required to enable the determination of ($k/m$), and hence $k$, to a reasonable accuracy, since the velocity must be allowed to increase to the point at which drag has a significant influence on the model's behavior.
The minimum distance needed for an accurate determination decreases as ($k/m$) increases, but something on the order of #qty(10, "m") seems to be the limit for any reasonable test model -- even if it is of lightweight construction and dropped without its engine.
This means that a tower or building of some sort must be used for drop testing, and that the model must be cushioned at the end of its fall to avoid damage.
Not all models can be tested in this manner; no amount of cushioning, for instance, can protect a model of the Saturn-V.
The drop test, like the vertical wind tunnel, is suitable only for determining the drag parameter at a zero angle of attack -- but it also eliminates the need for a balance system and has the added advantage that the test takes place in the open air, so that there are no tunnel wall effects.
// === page 235 ===
// Figure 55
#figure(
  image("../../assets/figures-original/fig3-55.png"),
  caption: [A "drop chart" of the type that might be used in determining the drag parameter k of a model rocket from vertical drop tests.
  Curves are presented for drop distances of 10, 25, 50, and 100 meters.
  The curves flatten at the top because $k/m$ becomes great enough for the rocket to attain its terminal velocity within the specified drop distance, after which the drop time becomes roughly proportional to $sqrt(k/m)$.
  For the smaller drop distances accurate determinations of k cannot be made without extremely accurate timing devices.]
) <fig:drop-chart>
// === page 236 ===
=== Conclusion <sec:ch3-conclusion>
The relative merits of the three experimental techniques described above can only be properly judged at such time as all three have been tried in practice and developed to the highest level of effectiveness of which it is reasonable to believe they are capable.
It is our hope that, in the near future, each of them will be tried and that an extensive experimental literature will be generated within the hobby as a result, for only a large body of reliable experimental data can permit us to verify or improve upon the techniques herein described for the analytical prediction of model rocket drag.
// === page 237 ===
#bibliography("../refs-ch3.yml", style: "ieee", title: "References", group: none)
