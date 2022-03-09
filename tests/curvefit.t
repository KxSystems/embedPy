.t.requiremod`scipy.optimize
cf:.p.import[`scipy.optimize;`:curve_fit;<]

// Update to align with xexp optimization in kdb+ 4.0 2020.07.15
ver:enlist enlist$[(.z.K>=4)&.z.k>=2020.07.15;0f;3.4660897158452992e-32];
(enlist 2f;ver)~cf[{x xexp y};0 1 2 3 4;0 1 4 9 16f;1f]
