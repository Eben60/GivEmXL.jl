## Creating a project from template

```
using GivEmExel: makeproj

makeproj("/my_projects/MyProject/", "MyProject", "scrpt"; authors=["1st author", "2nd author"])
```

This will create a `GivEmExel` based project from the default template. The project will be named `MyProject` and put into the folder `/my_projects/MyProject/`, with scripts named `scrpt.sh` and `scrpt.bat`, among other things. 

```
using GivEmExel: makeproj

makeproj("/my_projects/MyToyProject/", "MyToyProject", "rcex2", :example1; authors=["1st author", "2nd author"])
```

will create a project based on our [Toy Example](@ref "Toy Example: Fit exp decay curves"). See also [`makeproj` documentation](@ref GivEmExel.makeproj).

### Referring to other in-house `julia` projects in your project.

Our aim is to have end user just run `instantiate.bat` once to set up the environment. If your project must refer to some in-house projects, not registered in the General Registry, you can simply copy these projects into a subfolder of your projects. If you generate you project from the default template, as shown above, your project will contain a placeholder for such a dependency. Alternatively you can add dependencies from a file server: for this case, uncomment and adjust the corresponding line in the `instantiate.jl` file. 