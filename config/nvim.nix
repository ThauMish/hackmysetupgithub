{ config, pkgs, ... }:

let
  # Function to read all file in nvim/*
  readRecursiveDir = path: 
    let
      files = builtins.readDir path;
      subdirs = builtins.filter (name: files.${name}.type == "directory") (builtins.attrNames files);
      nestedFiles = builtins.concatMap (dir: builtins.mapAttrs (_: subfile: "${dir}/${subfile}") (readRecursiveDir (path + "/" + dir))) subdirs;
    in
      builtins.mapAttrs (name: value: "${path}/${name}") (builtins.removeAttrs files subdirs) // builtins.listToAttrs (builtins.map (file: {name = file; value = file;}) nestedFiles);

  # Function to paste config of nvim in .config of the user
  nvimFiles = readRecursiveDir ./nvim;
in {
  home.file = builtins.mapAttrs (name: value: {
    target = ".config/nvim/" + name;
    source = value;
  }) nvimFiles;
}

