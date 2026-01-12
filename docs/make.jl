using Documenter, MatrixEnsembles

format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true",
                         assets = ["assets/favicon.ico"]
)

makedocs(
    clean = true,
    format = format,
    sitename = "MatrixEnsembles.jl",
    authors = "Łukasz Pawela",
    pages = [
        "Home" => "index.md",
        "Manual" => Any[
            "man/quickstart.md",
            "man/random.md"
        ],
        "Library" => "lib/MatrixEnsembles.md"
    ]
)

# deploydocs(
#     deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
#     target = "build",
#     repo = "github.com/iitis/MatrixEnsembles.jl.git"
# )
