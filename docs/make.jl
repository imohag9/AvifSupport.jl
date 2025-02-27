using AvifSupport
using Documenter

DocMeta.setdocmeta!(AvifSupport, :DocTestSetup, :(using AvifSupport); recursive=true)

makedocs(;
    modules=[AvifSupport],
    authors="imohag9 <souidi.hamza90@gmail.com> and contributors",
    sitename="AvifSupport.jl",
    format=Documenter.HTML(;
        canonical="https://imohag9.github.io/AvifSupport.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/imohag9/AvifSupport.jl",
    devbranch="main",
)
