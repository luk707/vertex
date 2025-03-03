.PHONY: run all clean kernel busybox hello rootfs

all: kernel rootfs

run: kernel rootfs
	qemu-system-x86_64 -kernel linux/arch/x86/boot/bzImage -initrd initramfs.cpio

clean:
	rm -f initramfs.cpio
	rm -rf rootfs
	+$(MAKE) clean -C prog/hello

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

rootfs: hello
	if [ ! -d busyboxrootfs ]; then $(MAKE) busybox; fi

	rm -rf rootfs
	mkdir rootfs

	cp init rootfs/init
	cp -r busyboxrootfs/* rootfs
	cp prog/hello/hello rootfs/bin/hello

	cd rootfs && mkdir dev proc sys
	cd rootfs && find . | cpio -o --format=newc > ../initramfs.cpio
