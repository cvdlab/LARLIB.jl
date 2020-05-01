
using ViewerGL; GL = ViewerGL
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


#	1D complex in 2D generated by Lar and PLaSM operators
circle = Lar.circle()()
GL.VIEW([ GL.GLFrame2, GL.GLGrid( circle...,GL.COLORS[1],1 ) ]);

intervals = Lar.qn(1)([1.5,1.5])
GL.VIEW([ GL.GLFrame2, GL.GLGrid( intervals...,GL.COLORS[1],1 ) ]);

#	2D complex in 3D generated by Lar and PLaSM operators
cylinders = Lar.larModelProduct([ circle, intervals ])
GL.VIEW([ GL.GLFrame2, GL.GLGrid( cylinders...,GL.COLORS[1],1 ) ]);





disk = Lar.ring(0,1)([16,1])
interval0 = Lar.qn(1)([-3])
interval = Lar.qn(1)([1.5,1.5])
cylinder = Lar.larModelProduct([ disk, interval0 ])


circle(1)([16])
cylinder = Lar.larModelProduct([ circle, interval ])
even = [k for k=1:32 if k%2==0]
odd  = [k for k=1:32 if k%2==1]


function cylinder(r,h,n,k)
	circle = Lar.circle(r)([n])
	interval = Lar.qn(k)([h])
	V,FV = Lar.larModelProduct([ circle, interval ])
	push!(FV, [k for k=1:2*n if k%2==0])
	push!(FV, [k for k=1:2*n if k%2==1])
	return V,FV
end

V, FV = cylinder(1,3,16,1)

function displayModel(model, exp = 1.5)
    V = model.G
    EV = Lar.cop2lar(model.T[1])
    FE = Lar.cop2lar(model.T[2])
    CF = Lar.cop2lar(model.T[3])
    FV = Lar.cop2lar(map(x -> Int8(x/2), abs.(model.T[2]) * abs.(model.T[1])))
    CV = []
    triangulated_faces = Lar.triangulate(convert(Lar.Points, V'), [model.T[1], model.T[2]])
    FVs = convert(Array{Lar.Cells}, triangulated_faces)
    EVs = Lar.FV2EVs(model.T[1], model.T[2])

    GL.VIEW([
        GL.GLAxis( GL.Point3d(0,0,0),GL.Point3d(1,1,1) )
        GL.GLPol(V,EV, GL.COLORS[1])
    ]);
    GL.VIEW(GL.GLExplode(V,FVs,exp,exp,exp,99));
    GL.VIEW(GL.GLExplode(V,EVs,exp,exp,exp,99,1));
end

