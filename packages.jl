using Pkg

dependencies = [
    Pkg.PackageSpec(;name="IJulia", version="1.23.3"),
    Pkg.PackageSpec(;name="Plots", version="1.25.7")
]

Pkg.add(dependencies)