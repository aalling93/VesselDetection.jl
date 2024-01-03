### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils


begin
    using Pkg
    using DotEnv
    include("src/test_name.jl")
    using .Test_name
    import PlutoUI
    
end


# ╔═╡ 532e57e1-be06-4023-9c43-22e876a46867
begin
	access_token = Test_name.Download.get_access_token_copernicus(username = get(ENV, "DATASPACE_USERNAME", ""), password = get(ENV, "DATASPACE_PASSWORD", ""));
	print("access_token")
end

# ╔═╡ 62395347-2794-4e7b-8405-19fa492aeec6
access_token

# ╔═╡ b5ce56cd-abe2-45c0-ba84-538c0b3a65dc
begin
	a = 2
	a
end

# ╔═╡ Cell order:
# ╠═532e57e1-be06-4023-9c43-22e876a46867
# ╠═62395347-2794-4e7b-8405-19fa492aeec6
# ╠═b5ce56cd-abe2-45c0-ba84-538c0b3a65dc
