{ pkgs, pkgs-unstable, lib, config, ... }:

{
  options = {
    homerow.enable = lib.mkEnableOption "enables homerow mods";
  };

  config = lib.mkIf config.homerow.enable {
    # services.kanata = {
    #   enable = true;

    #   keyboards.abc.config = ''
    #     ;; Caps to escape/control configuration for Kanata
    #     (defsrc
    #       f1   f2   f3   f4   f5   f6   f7   f8   f9   f10   f11   f12
    #       caps a s d f j k l ;
    #     )

    #     (defvar
    #       tap-time 150
    #       hold-time 200
    #     )

    #     ;; Definine two aliases, one for esc/control to other for function key
    #     (defalias
    #       escctrl (tap-hold 100 100 esc lctl)
    #       a (tap-hold $tap-time $hold-time a lmet)
    #       s (tap-hold $tap-time $hold-time s lalt)
    #       d (tap-hold $tap-time $hold-time d lsft)
    #       f (tap-hold $tap-time $hold-time f lctl)
    #       j (tap-hold $tap-time $hold-time j rctl)
    #       k (tap-hold $tap-time $hold-time k rsft)
    #       l (tap-hold $tap-time $hold-time l ralt)
    #       ; (tap-hold $tap-time $hold-time ; rmet)
    #     )

    #     (deflayer base
    #       brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
    #       @escctrl @a @s @d @f @j @k @l @;
    #     )

    #     (deflayer fn
    #       f1   f2   f3   f4   f5   f6   f7   f8   f9   f10   f11   f12
    #       @escctrl _ _ _ _ _ _ _ _
    #     )
    #   '';
    # };
  };
}