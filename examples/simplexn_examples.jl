using LinearAlgebraicRepresentation
using LARVIEW

VOID = [[]], [[1]]


# example 1

V = [[0,0] [1,0] [2,0] [0,1] [1,1] [2,1] [0,2] [1,2] [2,2]];
FV = [[1,2,4],[2,3,5],[3,5,6],[4,5,7],[5,7,8],[6,8,9]];
pattern = repeat([1,2,-3],outer=4);
model = (V,FV);
W,FW = LinearAlgebraicRepresentation.extrudeSimplicial(model, pattern);
LARVIEW.view(W,FW)

# example 2

model = LinearAlgebraicRepresentation.extrudeSimplicial( VOID, ones(10) )
LARVIEW.view(model)
model = LinearAlgebraicRepresentation.extrudeSimplicial( model, ones(10) )
LARVIEW.view(model)
model = LinearAlgebraicRepresentation.extrudeSimplicial( model, ones(10) )
LARVIEW.view(model)


# example 3

model = LinearAlgebraicRepresentation.extrudeSimplicial( VOID, repeat([1,-1],outer=10) )
LARVIEW.view(model)
model = LinearAlgebraicRepresentation.extrudeSimplicial( model, repeat([1,-1],outer=10) )
LARVIEW.view(model)


# example 4

grid_2d = LinearAlgebraicRepresentation.simplexGrid([3,3])
LARVIEW.view(grid_2d)
grid_3d = LinearAlgebraicRepresentation.simplexGrid([2,3,4])
LARVIEW.view(grid_3d)
V,CV = LinearAlgebraicRepresentation.simplexGrid([1,1,1])
LARVIEW.view(V,CV)

# example 5

SK2 = LinearAlgebraicRepresentation.simplexFacets(CV)
LARVIEW.view(V, SK2)
SK1 = LinearAlgebraicRepresentation.simplexFacets(SK2)
LARVIEW.view(V, SK1)

