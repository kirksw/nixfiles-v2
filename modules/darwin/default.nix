{ lib, ... }: {
    imports = 
        lib.filesystem.listFilesRecursive ./toggle;
}