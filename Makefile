.PHONY: run all clean kernel busybox hello mervin rootfs

all: kernel rootfs

run: kernel rootfs
	qemu-system-x86_64 -m 2G -kernel linux/arch/x86/boot/bzImage -initrd initramfs.cpio

clean:
	rm -f initramfs.cpio
	rm -rf rootfs busyboxrootfs
	+$(MAKE) clean -C prog/hello
	+$(MAKE) clean -C prog/mervin

kernel:
	cp kernel.config linux/.config
	if [ ! -e linux/arch/x86/boot/bzImage ]; \
		then $(MAKE) -j $(nproc) -C linux; \
	fi

busybox:
	cp busybox.config busybox/.config
	+$(MAKE) install -j $(nproc) -C busybox CONFIG_PREFIX=../busyboxrootfs
	rm -f busyboxrootfs/linuxrc

hello:
	+$(MAKE) hello -C prog/hello

mervin:
	+$(MAKE) mervin -C prog/mervin

rootfs: hello mervin
	if [ ! -d busyboxrootfs ]; then $(MAKE) busybox; fi

	rm -rf rootfs
	mkdir rootfs
	./copy_libraries.sh
	cd rootfs && mkdir dev proc sys

	cp init rootfs/init
	cp -r busyboxrootfs/* rootfs
	cp prog/hello/hello rootfs/bin/hello
	cp prog/mervin/mervin rootfs/bin/mervin

	cd rootfs && find . | cpio -o --format=newc > ../initramfs.cpio
