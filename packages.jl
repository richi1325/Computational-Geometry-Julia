using Pkg

dependencies = [
    Pkg.PackageSpec(;name="IJulia", version="1.23.3"),
    Pkg.PackageSpec(;name="Plots", version="1.25.7"),
    Pkg.PackageSpec(;name="DataStructures", version="0.18.13"),
    Pkg.PackageSpec(;name="LazySets", version="1.57.0")    
]

Pkg.add(dependencies)