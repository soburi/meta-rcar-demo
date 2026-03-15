FILESEXTRAPATHS:prepend:r8a779g3 = "${TOPDIR}/../../../proprietary:"

# libegl.bb is the selected EGL provider in the DomD graphics stack.
# Keep gles-user-module as the GLES2 provider only to avoid a virtual/egl clash.
PROVIDES:remove = "virtual/egl"
