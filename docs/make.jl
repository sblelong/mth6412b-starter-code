using Documenter
using STSP

makedocs(
    sitename="STSP",
    format=Documenter.HTML(),
    modules=[STSP]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo="github.com/MaxenceGollier/mth6412b-starter-code"
)
