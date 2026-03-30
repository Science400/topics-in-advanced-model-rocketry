# Chapter 3 — Symbol Disambiguation

## How to use this file
`resolve.py` injects it into every conflict-resolution prompt as authoritative ground truth.

---

## OCR Error Substitutions

These are **OCR mistakes** made by specific models. The left column is WRONG; the right
column is CORRECT. When any model's output contains a WRONG token, replace it.

| WRONG (OCR error — not a valid symbol) | CORRECT | Notes |
| --- | --- | --- |
| `f` used as a variable (alone or in expressions: `\Delta f`, `f/c`, etc.) | `\rho` | lighton misreads `\rho` as `f` everywhere — in ALL positions |
| `f_0`, `f_o`, `f0` | `\rho_0` | lighton misreads subscripted `\rho_0` |
| `P` (uppercase, used as pressure variable) | `p` (lowercase) | chandra error |
| `\delta` (lowercase delta as a difference operator) | `\Delta` (uppercase) | olmocr, lighton |

`f` is NOT a valid symbol anywhere in this chapter — always a misread `\rho`.
This applies inside compound expressions too: `\Delta f` → `\Delta \rho`, `f/c` → `\rho/c`.

---

## Variable Definitions (Chapter 3)

Fill in from the chapter's symbol table pages after OCR + manual review:

| LaTeX | Meaning |
| --- | --- |
| `A` | Area |
| `A_c` | face area of elastic cube |
| `A_{lug}` | frontal area of launch lug |
| `A_r` | reference area for determining drag coefficient |
| `AR` | aspect ratio |
| `\Delta AR` | change in effective aspect ratio due to lateral displacement of tip vortices |
| `B` | function of critical Reynolds number used in analysis of boundary-layer transition |
| `C_D` | coefficient of drag |
| `C_{Db}` | base drag coefficient |
| `(C_{Db})_m` | base drag coefficient based on maximum frontal cross-sectional area |
| `C_{DB}(\alpha)` | coefficient of body drag due to angle of attack |
| `C_{Dc}` | cross-flow drag coefficient of a circular cylinder of infinite length |
| `C_{Df}` | forebody drag coefficient; also fin friction drag coefficient based on area of one side of fin |
| `\Delta C_{Df}` | increase in fin friction drag coefficient due to the effect of fin thickness |
| `C_{Df}'` | fin friction drag coefficient corrected for the effect of fin thickness |
| `C_{DI}` | coefficient of interference drag at zero angle of attack |
| `(C_{Df})_b` | forebody drag coefficient as used in Datcom equations |
| `C_{Di}` | induced drag coefficient of fins based on fin area in side view |
| `C_{Di}'` | induced drag coefficient of fins based on maximum frontal cross-sectional area |
| `(C_{Di}')_{cant}` | increase in drag coefficient due to canting of fins |
| `(C_D)_{lug}` | drag coefficient of launch lug based on lug frontal area |
| `(\Delta C_D)_{lug}` | increase in vehicle drag coefficient based on maximum frontal cross-sectional area, due to the presence of a launch lug |
| `(C_{D0})_B` | body drag coefficient at zero angle of attack |
| `(C_{D0})_F` | fin drag coefficient at zero angle of attack |
| `(C_{D0})_{FB}` | drag coefficient of fin/body assembly at zero angle of attack |
| `C_{Ds}` | subsonic drag coefficient |
| `C_{Dv}` | friction drag coefficient |
| `C_{D \alpha}` | coefficient of drag due to angle of attack |
| `C_f` | skin friction coefficient |
| `C_{fb}` | forebody friction drag coefficient based on cross-sectional area of base |
| `(C_f)_B` | skin friction coefficient of body |
| `\Delta C_f` | change in skin friction coefficient |
| `(C_f)_F` | skin friction coefficient of fins |
| `(C_f)_{lam}` | laminar skin friction coefficient |
| `(C_f')_{lam}` | corrected laminar skin friction coefficient |
| `(\Delta C_f)_{lam}` | increase in laminar skin friction coefficient due to 3-dimensional effects |
| `(C_f)_{turb}` | turbulent skin friction coefficient |
| `(C_f')_{turb}` | corrected turbulent skin friction coefficient |
| `(\Delta C_f)_{turb}` | increase in turbulent skin friction coefficient due to 3-dimensional effects |
| `C_L` | coefficient of "lift" or side force |
| `C_p` | coefficient of pressure |
| `D` | drag |
| `D_a` | approximating function for drag based on the assumption of a constant drag coefficient |
| `D_b` | base drag |
| `D_e` | exact drag as determined by Datcom method |
| `D_f` | pressure foredrag |
| `D_p` | pressure drag |
| `D_v` | skin friction drag |
| `D_\alpha` | drag due to angle of attack |
| `E` | modulus of elasticity |
| `F` | shearing force |
| `G` | torsional or shear modulus of elastic solid |
| `G_1(), G_2(), G_3(), G_4(), G_5()` | drag coefficients expressed as functions of Datcom parameters |
| `H_1(), H_2(), H_3(), H_4(), H_5(), H_6()` | drag coefficients expressed as functions of Datcom parameters for General Configuration Rocket |
| `K_{B(F)}` | body side force interference factor |
| `K_{F(B)}` | fin side force interference factor |
| `L` | characteristic length |
| `M` | Mach number |
| `P` | perimeter of body cross section |
| `R` | Reynolds number |
| `R_c` | Reynolds number based on fin chord |
| `R_{crit}` | critical Reynolds number |
| `R_k` | roughness Reynolds number |
| `(R_k)_t` | critical roughness Reynolds number |
| `R_l` | Reynolds number based on length |
| `R_x` | local Reynolds number based on longitudinal coordinate |
| `S` | surface area |
| `S_b` | base cross sectional area |
| `S_E` | exposed planform area of all fins |
| `S_e` | exposed fin planform area in side view |
| `S_F` | planform area of fins in side view, including "hidden" area projected within body; also total planform area of all fins as used in Datcom equations |
| `S_m` | maximum frontal cross sectional area of body |
| `S_0` | frontal cross sectional area of body at x_0 |
| `S_s` | forebody wetted area |
| `S_x` | frontal cross sectional area of body at x |
| `T` | temperature |
| `T_std.` | temperature of standard, sea-level atmosphere |
| `U` | free-stream longitudinal velocity, airspeed |
| `U_{\infty}` | free-stream longitudinal velocity as used in boundary layer analysis |
| `V` | volume; also velocity |
| `\vec{V}` | vector velocity |
| `\Delta V` | change in volume |
| `V_0` | initial volume |
| `b` | span; also width |
| `c` | speed of sound; also fin chord |
| `c_{std.}` | speed of sound in standard, sea-level atmosphere |
| `d( )` | differential of ( ) |
| `d( )/d( )` | derivative |
| `d^2( )/d( )^2` | second derivative |
| `d_b` | base diameter |
| `d_{eqiv.}` | equivalent diameter |
| `d_{lug}` | diameter of launch lug |
| `d_m` | maximum diameter of body, used as reference diameter in Datcom equations |
| `d_r` | reference diameter |
| `f( )` | function of ( ) |
| `g` | acceleration of gravity |
| `h` | height or thickness of fluid layer; also height of control volume in momentum-integral boundary layer analysis |
| `k` | drag parameter as used in Chapter 4 |
| `k_{adm}` | admissible roughness height |
| `k_{crit}` | critical height of transverse cylindrical roughness element |
| `k_t` | critical height of distributed roughness particles |
| `(k_2 - k_1)` | apparent mass factor |
| `l` | length; also distance measured around body profile, starting at nose |
| `l_b` | body length |
| `l_T` | length of boattail |
| `n` | rotation rate, revolutions per second |
| `n` | unit normal vector |
| `p` | pressure |
| `\Delta p` | change in pressure |
| `p_b` | base pressure |
| `p_o` | ambient static pressure |
| `p_s` | static pressure |
| `p_{s(stag.)}` | static pressure at a stagnation point |
| `p_{tot}` | total pressure |
| `p_{\infty}` | free-stream static pressure |
| `q` | dynamic pressure |
| `\Delta q` | change in dynamic pressure |
| `r` | radius |
| `r_x` | radius of body at station x |
| `s` | distance coordinate measured along surface |
| `t` | time; also fin thickness |
| `t` | unit tangent vector |
| `u` | longitudinal component of flow velocity; also circumferential velocity of the surface of a spinning rocket |
| `u_k` | longitudinal flow velocity at the top of a roughness element |
| `v` | transverse component of flow velocity |
| `x` | longitudinal coordinate; also distance fallen by rocket undergoing a drop test |
| `x_{crit}` | longitudinal location of transition point |
| `x_0` | longitudinal station on body where flow ceases to obey potential theory |
| `x_1` | station on body where dS_x/dx first reaches its minimum value |
| `y` | coordinate perpendicular to surface |
| `\Delta( )` | change in ( ) |
| `\alpha` | angle of attack; also f''(0) in Blasius boundary-layer analysis |
| `\bar{\alpha}` | average effective angle of attack |
| `\gamma` | engineering shear strain |
| `\delta` | boundary layer thickness |
| `\epsilon` | boattail angle; also parameter of drag due to angle of attack as used in Chapter 4 |
| `\eta` | dimensionless coordinate perpendicular to surface; also ratio of cross-flow drag on a cylinder of finite length to cross-flow drag on a cylinder of infinite length |
| `\eta_B` | `\eta` as defined in Blasius analysis, `2\eta_3` |
| `\eta_k` | nondimensional roughness height |
| `\eta_3` | `\eta` as used in reference 3 |
| `\theta` | deformation angle of elastic solid; also momentum thickness of boundary layer; also angle of fin cant |
| `\mu` | absolute viscosity |
| `\nu` | kinematic viscosity |
| `\rho` | mass density |
| `\Delta \rho` | change in mass density |
| `\rho_o` | initial mass density |
| `\rho_{\text{std.}}` | mass density of standard sea-level atmosphere |
| `\sigma_E` | exposed planform area of one fin |
| `\sigma_F` | planform area of one fin, including projected area "hidden" within body |
| `\tau` | shearing stress |
| `\tau_o` | shearing stress at surface |
| `\tau_{ok}` | surface shear stress at station of roughness element |
| `\phi` | angle of deviation between perpendicular to free stream and perpendicular to surface |
| `\varphi` | central angle of a point on the surface of a cylinder held transverse to the stream, measured from the stagnation point |
| `\psi` | streamfunction |
| `\omega_z` | rotation rate, radians per second |
| `\partial( )` | partial differential of ( ) |
| `\partial( )/\partial( )` | partial derivative |
| `\partial^2( )/\partial( )^2` | second partial derivative |
| `\infty` | infinity |



---

## Equation Number Format

olmocr places equation numbers **before** display equations as `(N) \[...\]`.
lighton places them as standalone lines or `(N) $...$`.
chandra embeds them inside `<math display="block">` tags.
The pipeline normalises all three; equation numbers should NOT appear in resolved text.

