using SparseArrays


function arrange3Dfaces(V, copEV, copFE)
	EVs = Lar.FV2EVs(copEV, copFE) # polygonal face fragments

	triangulated_faces = Lar.triangulate2D(V, [copEV, copFE])
	FVs = convert(Array{Lar.Cells}, triangulated_faces)
	V = convert(Lar.Points,V')
	return V,FVs,EVs
end


V = [0.6540617999999998 0.2054992 0.2972308000000001; 0.7142364999999998 0.1455625 0.969203; 0.6872816200343089 0.1724107693563844 0.6681972618528844; 0.5941250999999997 0.8769965 0.36249240000000005; 0.6542998079614951 0.8170598007732168 1.0344646993560203; 0.6929229746417847 0.3843473621810608 0.9924101013070119; 0.6660927570227951 0.3906268097799347 0.66824889023436; 0.6924256885846046 0.3894687221287142 0.9924113129852241; 1.3260341 0.2707609000000001 0.2428771; 1.3862088 0.21082410000000004 0.9148494000000003; 1.2660973 0.9422582000000003 0.3081388; 1.3262719920385087 0.8823213992267827 0.9801110006439793; 0.7946185131077457 0.1533691699791747 0.9627011677876783; 0.795311803386693 0.18207414025178234 0.6679835359595829; 0.8049461769791598 0.3844586322271989 0.9823884300888783; 0.6978893364451173 0.3892254686183435 0.9924004714668809; -0.38740630000000004 0.49022260000000006 0.45363390000000015; 0.3249123 0.707347 0.5231232000000001; -0.17028190000000007 -0.08642419999999995 0.029717700000000125; 0.542036694733776 0.13070013212634024 0.09920695360173326; -0.317917 0.06630639999999999 1.0658723; 0.3944015999999999 0.28343080000000004 1.1353616; -0.10079260000000007 -0.5103404 0.6419561000000001; 0.6115259947337761 -0.2932160678736597 0.7114453536017331; 0.4729938678063347 0.07470259548304928 0.9819171231357612; 0.4673971777131105 0.08956648867512645 0.992844167328483; 0.4666328572520818 0.07498584149882567 0.9828352213039846; 0.19232632825298282 -0.12794307378859587 0.27191838727041745; 0.06793576156374279 -0.27817482626798234 0.4125651841369061; 0.11898101245114942 -0.28171847559315566 0.44353026597502554; -0.22025999018892456 -0.06114183775734239 0.4630346767698157; -0.21520721568246745 -0.07974293126956722 0.4693603419651943; -0.22039804348690156 -0.06683826697471296 0.4822487320160556; 0.5039882186318663 0.07330882745780876 0.6685562398308738; 0.4707836778272794 0.18222015069807973 0.6686268661789595; 0.4673140236772549 0.08983923498806379 0.9928443441979011; 0.7899025999999999 0.060579300000000016 0.6679888999999999; 0.46601 0.0749997 0.6686315999999999; 0.8043229999999999 0.38447249999999994 0.6679745999999999; 0.4804303999999999 0.3988929 0.6686172999999999; 0.7905452000000002 0.060564999999999994 0.9922023000000001; 0.46665270000000003 0.0749854 0.9928450000000001; 0.8049656 0.3844582 0.9921880000000001; 0.4810731000000001 0.3988786 0.9928307000000001; -0.22619069999999997 -0.07204550000000004 0.47156350000000014; -0.04998879999999989 0.08634890000000003 0.7965885000000001; -0.06779629999999998 0.21916400000000003 0.24378000000000005; 0.1084055869015021 0.3775584091796722 0.5688049026274027; 0.09883429999999994 -0.29982910000000007 0.4063673; 0.27503619999999995 -0.14143470000000002 0.7313923; 0.2572285999999999 -0.008619600000000005 0.17858379999999996; 0.4334305216010028 0.14977485494346238 0.503608715725915];
copEV = SparseArrays.sparse([1, 4, 14, 2, 5, 15, 1, 2, 7, 17, 3, 4, 19, 3, 6, 20, 5, 6, 9, 23, 7, 8, 52, 53, 8, 9, 60, 61, 10, 12, 14, 10, 13, 16, 11, 12, 19, 11, 13, 20, 15, 16, 18, 21, 17, 18, 54, 55, 21, 22, 68, 69, 22, 23, 59, 60, 24, 26, 36, 24, 27, 37, 25, 26, 38, 25, 27, 39, 28, 30, 36, 28, 31, 37, 29, 30, 38, 29, 33, 39, 32, 33, 34, 47, 31, 32, 35, 49, 71, 72, 73, 34, 35, 66, 67, 40, 41, 83, 84, 40, 42, 87, 88, 41, 42, 80, 81, 43, 44, 77, 78, 43, 45, 86, 87, 44, 45, 74, 75, 46, 47, 50, 51, 46, 48, 56, 57, 73, 48, 49, 63, 64, 50, 54, 65, 51, 56, 66, 52, 55, 68, 53, 57, 70, 58, 62, 65, 58, 63, 67, 71, 59, 62, 69, 61, 64, 70, 72, 74, 77, 86, 75, 79, 89, 76, 78, 90, 76, 79, 91, 80, 83, 88, 81, 85, 89, 82, 84, 90, 82, 85, 91], [1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24, 24, 24, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 28, 28, 28, 28, 29, 29, 29, 29, 30, 30, 30, 30, 31, 31, 31, 31, 32, 32, 32, 32, 33, 33, 33, 33, 34, 34, 34, 34, 35, 35, 35, 35, 35, 36, 36, 36, 36, 37, 37, 37, 38, 38, 38, 39, 39, 39, 40, 40, 40, 41, 41, 41, 42, 42, 42, 42, 43, 43, 43, 44, 44, 44, 44, 45, 45, 45, 46, 46, 46, 47, 47, 47, 48, 48, 48, 49, 49, 49, 50, 50, 50, 51, 51, 51, 52, 52, 52], Int8[-1, -1, -1, -1, -1, -1, 1, 1, -1, -1, -1, 1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, 1, 1, -1, -1, -1, -1, 1, 1, -1, -1, -1, 1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, -1, 1, -1, 1, -1, -1, 1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, 1, -1, -1, -1, -1, -1, -1, 1, -1, -1, 1, 1, 1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1, 1, 1, 1, -1, -1, 1, 1, -1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1, -1, 1, -1, 1, 1, -1, 1, 1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1]);
copFE = SparseArrays.sparse([1, 4, 2, 5, 1, 6, 1, 7, 2, 8, 1, 9, 1, 2, 20, 22, 1, 2, 27, 28, 1, 2, 23, 24, 3, 4, 3, 6, 3, 7, 3, 9, 4, 7, 5, 8, 4, 9, 4, 5, 20, 22, 4, 5, 30, 31, 6, 7, 6, 9, 8, 9, 30, 31, 8, 9, 27, 29, 8, 9, 23, 24, 10, 13, 10, 14, 10, 16, 10, 18, 11, 13, 11, 14, 11, 16, 11, 18, 12, 19, 11, 18, 11, 12, 25, 26, 11, 12, 32, 34, 13, 16, 13, 18, 14, 16, 14, 18, 14, 15, 44, 45, 14, 15, 37, 38, 14, 15, 40, 41, 16, 17, 43, 44, 16, 17, 35, 36, 16, 17, 39, 40, 18, 19, 20, 21, 18, 19, 25, 26, 18, 19, 18, 19, 20, 25, 21, 26, 22, 27, 20, 28, 20, 30, 22, 31, 21, 32, 20, 33, 23, 25, 23, 29, 24, 27, 23, 28, 23, 30, 23, 23, 25, 30, 26, 32, 25, 34, 27, 31, 29, 30, 28, 33, 34, 33, 32, 33, 35, 39, 36, 40, 36, 42, 35, 43, 36, 44, 36, 46, 37, 41, 38, 40, 38, 42, 37, 45, 38, 44, 38, 46, 39, 43, 40, 44, 41, 45, 40, 46, 42, 44, 42, 46], [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 30, 30, 31, 31, 32, 32, 33, 33, 34, 34, 34, 34, 35, 35, 35, 35, 36, 36, 37, 37, 38, 38, 39, 39, 40, 40, 40, 40, 41, 41, 41, 41, 42, 42, 42, 42, 43, 43, 43, 43, 44, 44, 44, 44, 45, 45, 45, 45, 46, 46, 46, 46, 47, 47, 47, 47, 48, 48, 49, 49, 50, 50, 51, 51, 52, 52, 53, 53, 54, 54, 55, 55, 56, 56, 57, 57, 58, 58, 59, 59, 60, 60, 61, 61, 62, 62, 63, 64, 65, 65, 66, 66, 67, 67, 68, 68, 69, 69, 70, 70, 71, 72, 73, 73, 74, 74, 75, 75, 76, 76, 77, 77, 78, 78, 79, 79, 80, 80, 81, 81, 82, 82, 83, 83, 84, 84, 85, 85, 86, 86, 87, 87, 88, 88, 89, 89, 90, 90, 91, 91], Int8[1, 1, -1, -1, -1, 1, -1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, -1, 1, -1, -1, 1, -1, 1, 1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, 1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, 1, -1, 1, 1, -1, 1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, -1, -1, -1, -1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, 1, -1, -1, 1, 1, 1, 1, -1, 1, -1, -1, 1, -1, 1, 1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 1, -1, 1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, 1, 1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, -1, -1, 1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, -1, 1, 1, -1, -1, 1, 1, 1, -1, 1, 1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, 1]);

V,FVs,EVs = arrange3Dfaces(V, copEV, copFE);
GL.VIEW(GL.GLExplode(V,FVs,1.1,1.1,1.1,99,1));
GL.VIEW(GL.GLExplode(V,EVs,1.5,1.5,1.5,99,1));



V = [0.6540617999999998 0.2054992 0.2972308000000001; 0.7142364999999998 0.1455625 0.969203; 0.6872816200343089 0.1724107693563844 0.6681972618528844; 0.5941250999999997 0.8769965 0.36249240000000005; 0.6542998079614951 0.8170598007732168 1.0344646993560203; 0.6929229746417847 0.3843473621810608 0.9924101013070119; 0.6660927570227951 0.3906268097799347 0.66824889023436; 0.6924256885846046 0.3894687221287142 0.9924113129852241; 1.3260341 0.2707609000000001 0.2428771; 1.3862088 0.21082410000000004 0.9148494000000003; 1.2660973 0.9422582000000003 0.3081388; 1.3262719920385087 0.8823213992267827 0.9801110006439793; 0.7946185131077457 0.1533691699791747 0.9627011677876783; 0.795311803386693 0.18207414025178234 0.6679835359595829; 0.8049461769791598 0.3844586322271989 0.9823884300888783; 0.6978893364451173 0.3892254686183435 0.9924004714668809; -0.38740630000000004 0.49022260000000006 0.45363390000000015; 0.3249123 0.707347 0.5231232000000001; -0.17028190000000007 -0.08642419999999995 0.029717700000000125; 0.542036694733776 0.13070013212634024 0.09920695360173326; -0.317917 0.06630639999999999 1.0658723; 0.3944015999999999 0.28343080000000004 1.1353616; -0.10079260000000007 -0.5103404 0.6419561000000001; 0.6115259947337761 -0.2932160678736597 0.7114453536017331; 0.4729938678063347 0.07470259548304928 0.9819171231357612; 0.4673971777131105 0.08956648867512645 0.992844167328483; 0.4666328572520818 0.07498584149882567 0.9828352213039846; 0.5039882186318663 0.07330882745780876 0.6685562398308738; 0.4707836778272794 0.18222015069807973 0.6686268661789595; 0.4673140236772549 0.08983923498806379 0.9928443441979011; 0.7899025999999999 0.060579300000000016 0.6679888999999999; 0.46601 0.0749997 0.6686315999999999; 0.8043229999999999 0.38447249999999994 0.6679745999999999; 0.4804303999999999 0.3988929 0.6686172999999999; 0.7905452000000002 0.060564999999999994 0.9922023000000001; 0.46665270000000003 0.0749854 0.9928450000000001; 0.8049656 0.3844582 0.9921880000000001; 0.4810731000000001 0.3988786 0.9928307000000001];
copEV = SparseArrays.sparse([1, 4, 14, 2, 5, 15, 1, 2, 7, 17, 3, 4, 19, 3, 6, 20, 5, 6, 9, 23, 7, 8, 46, 47, 8, 9, 54, 55, 10, 12, 14, 10, 13, 16, 11, 12, 19, 11, 13, 20, 15, 16, 18, 21, 17, 18, 48, 49, 21, 22, 62, 63, 22, 23, 53, 54, 24, 26, 36, 24, 27, 37, 25, 26, 38, 25, 27, 39, 28, 30, 36, 28, 31, 37, 29, 30, 38, 29, 33, 39, 32, 33, 34, 41, 31, 32, 35, 43, 65, 66, 67, 34, 35, 60, 61, 40, 41, 44, 45, 40, 42, 50, 51, 67, 42, 43, 57, 58, 44, 48, 59, 45, 50, 60, 46, 49, 62, 47, 51, 64, 52, 56, 59, 52, 57, 61, 65, 53, 56, 63, 55, 58, 64, 66], [1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 22, 23, 23, 23, 24, 24, 24, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 28, 28, 28, 28, 29, 29, 29, 29, 29, 30, 30, 30, 30, 31, 31, 31, 32, 32, 32, 33, 33, 33, 34, 34, 34, 35, 35, 35, 36, 36, 36, 36, 37, 37, 37, 38, 38, 38, 38], Int8[-1, -1, -1, -1, -1, -1, 1, 1, -1, -1, -1, 1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, 1, 1, -1, -1, -1, -1, 1, 1, -1, -1, -1, 1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, -1, 1, -1, 1, -1, -1, 1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1, 1, 1, 1, -1, -1, 1, 1, -1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
copFE = SparseArrays.sparse([1, 4, 2, 5, 1, 6, 1, 7, 2, 8, 1, 9, 1, 2, 18, 20, 1, 2, 25, 26, 1, 2, 21, 22, 3, 4, 3, 6, 3, 7, 3, 9, 4, 7, 5, 8, 4, 9, 4, 5, 18, 20, 4, 5, 28, 29, 6, 7, 6, 9, 8, 9, 28, 29, 8, 9, 25, 27, 8, 9, 21, 22, 10, 13, 10, 14, 10, 15, 10, 16, 11, 13, 11, 14, 11, 15, 11, 16, 12, 17, 11, 16, 11, 12, 23, 24, 11, 12, 30, 32, 13, 15, 13, 16, 14, 15, 14, 16, 16, 17, 18, 19, 16, 17, 23, 24, 16, 17, 16, 17, 18, 23, 19, 24, 20, 25, 18, 26, 18, 28, 20, 29, 19, 30, 18, 31, 21, 23, 21, 27, 22, 25, 21, 26, 21, 28, 21, 21, 23, 28, 24, 30, 23, 32, 25, 29, 27, 28, 26, 31, 32, 31, 30, 31], [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 30, 30, 31, 31, 32, 32, 33, 33, 34, 34, 34, 34, 35, 35, 35, 35, 36, 36, 37, 37, 38, 38, 39, 39, 40, 40, 40, 40, 41, 41, 41, 41, 42, 42, 43, 43, 44, 44, 45, 45, 46, 46, 47, 47, 48, 48, 49, 49, 50, 50, 51, 51, 52, 52, 53, 53, 54, 54, 55, 55, 56, 56, 57, 58, 59, 59, 60, 60, 61, 61, 62, 62, 63, 63, 64, 64, 65, 66, 67, 67], Int8[1, 1, -1, -1, -1, 1, -1, 1, 1, 1, -1, -1, 1, -1, -1, 1, 1, -1, 1, -1, -1, 1, -1, 1, 1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, 1, 1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, 1, -1, 1, 1, -1, 1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, -1, -1, -1, -1, -1, 1, -1, -1, 1, -1, 1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, 1, -1, -1, 1, 1, 1, 1, -1, 1, -1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, 1, 1, 1, -1, -1, 1, 1, -1, -1, 1, -1, -1, 1, 1, 1, -1, 1, 1, 1, 1, -1, -1, -1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, -1, -1, 1, 1, 1, 1, -1, -1, 1]);

V,FVs,EVs = arrange3Dfaces(V, copEV, copFE);
GL.VIEW(GL.GLExplode(V,FVs,1.1,1.1,1.1,99,1));
GL.VIEW(GL.GLExplode(V,EVs,1.5,1.5,1.5,99,1));