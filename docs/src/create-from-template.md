## Creating a project from template

```
using GivEmXL: makeproj

makeproj("/my_projects/MyProject/", "MyProject", "scrpt"; authors=["1st author", "2nd author"])
```

This will create a `GivEmXL` based project from the default template. The project will be named `MyProject` and put into the folder `/my_projects/MyProject/`, with scripts named `scrpt.sh` and `scrpt.bat`, among other things. 

```
using GivEmXL: makeproj

makeproj("/my_projects/MyToyProject/", "MyToyProject", "rcex2", :example1; authors=["1st author", "2nd author"])
```

will create a project based on our [Toy Example #1](@ref "Toy Example #1: Fit exp decay curves"). See also [`makeproj` documentation](@ref GivEmXL.makeproj).

### Referring to other in-house `julia` projects in your project

Our aim is that the only thing the end user will have to do to set up the environment would be simply running `instantiate.bat` (resp. `instantiate.sh`) once. If your project refers to some in-house projects, not registered in the General Registry, you can simply copy these projects into a subfolder of your projects. In case you generate you project from the default template, as shown above, your project will contain the placeholder for such dependency in the `instantiate.jl` file. Alternatively you can add dependencies from a (file) server: for this case, uncomment and adjust the corresponding line in `instantiate.jl`. 