module ComputerVisionDatasets
# copyright 2015 Nicu Stiurca (nstiurca@seas.upenn.edu)

import Base: show, showall, showcompact
import SHA

# package code goes here

function getDefaultLocalPath()
  return joinpath(homedir(), "Data", "cv_datasets")
end

type Dataset
  name::String
  family::String
  url::ASCIIString
  sha::ASCIIString
end

type DatasetFamily
  name::String
  datasets::Vector{Dataset}
end

function showcompact(io::IO, ds::Dataset)
  print(io, "Dataset(\"$(ds.name)\")")
end

function show(io::IO, df::DatasetFamily)
  println(io, "DatasetFamily(\"$(df.name)\", [")
  for ds in df.datasets
    print(io, '\t')
    show(io, ds)
    println(io, ',')
  end
  println(io, "])")
end

filename(dataset::Dataset) = basename(dataset.url)
local_path(df::DatasetFamily) = joinpath(getDefaultLocalPath(), df.name)

function makeDatasetFamily(familyName, nameURL...)
  names = nameURL[1:3:end]
  URLs = nameURL[2:3:end]
  SHAs = nameURL[3:3:end]
  return DatasetFamily(familyName, Dataset[
            Dataset(name, familyName, url, sha) for (name,url,sha) in zip(names, URLs, SHAs)])
end

function fetch(ds::Dataset; check_sha=true)
  filepath = joinpath(getDefaultLocalPath(), ds.family, filename(ds))
  if !isfile(filepath)
    println("""Fetching dataset "$(ds.name)" from $(ds.url)""")
    download(ds.url, filepath)
  end

  if !isfile(filepath)
    error("Could not find local file '$filepath'")
  end

  if check_sha
    print("Checking SHA256 of '$filepath'... ")
    sha = "N/A"
    open(filepath, "r") do f
      sha = SHA.sha256(f)
    end
    print(sha)

    # check SHA256 (if provided)
    if length(ds.sha) == 64
      if sha == ds.sha
        println(" [OK]")
      else
        println(" [FAIL]")
        error("Expected SHA256 $(ds.sha)")
      end
    else
      println(" [WARN]")
      warn("No expected SHA256 provided for dataset '$(ds.name)'")
    end

    println("--")
  end   # if check_sha
end

function fetch(df::DatasetFamily; check_sha=true)
  println("""Fetching dataset family "$(df.name)" """)
  mkpath(local_path(df))
  for dataset in df.datasets
    fetch(dataset, check_sha=check_sha)
  end
end

LSD_SLAM() = makeDatasetFamily("LSD_SLAM",
              "LSD_room_images", "http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_room_images.zip",           "a5d10f1a2c1b6d31671e111c5a383f71932930d9743fa9d5fa460dbcb6ce5f81",
              "LSD_room_pc", "http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_room_pc.ply",                   "0e233d318d234dfef936c229cad784d6c279a8e4916c523ac8f3c5a6562e3bc7",
              "LSD_machine_images", "http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_machine_images.zip",     "064187347be844a91db30261f1af166276bfa291ece733411cb483dae81bcbb5",
              "LSD_machine_pc", "http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_machine_pc.ply",             "01aacf3c29346e47b0f6f42795c15af076c1d3c8cc3a56df1aeb59dd34bb5a66",
              "LSD_foodcourt_images", "http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_foodcourt_images.zip", "cce651ba6f26bcae3380c36938f43a8be62a5f5f4826129ea17884dd040ab782",
              "LSD_foodcourt_pc", "http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_foodcourt_pc.ply",         "031c4607688218bac689853111d4d4367248491392144c46a77b25e5a109d938",
              "LSD_eccv_images", "http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_eccv_images.zip",           "bce9df789dbeac92175ccc8c171054e3ac9cb353553bc59d6bf711bc15d2728e",
              "LSD_eccv_pc", "http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_eccv_pc.ply",                   "59eab221ca1b388f091317c4c25fc34babb29fe9cff505535fee21fce3f16961"
            )


end # module
