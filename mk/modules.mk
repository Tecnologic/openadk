# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

#
# Virtualization
#

$(eval $(call KMOD_template,KVM,kvm,\
	$(MODULES_DIR)/kernel/arch/${ARCH}/kvm/kvm \
,90))

$(eval $(call KMOD_template,KVM_AMD,kvm-adm,\
	$(MODULES_DIR)/kernel/arch/${ARCH}/kvm/kvm-amd \
,95))

$(eval $(call KMOD_template,KVM_INTEL,kvm-intel,\
	$(MODULES_DIR)/kernel/arch/${ARCH}/kvm/kvm-intel \
,95))

#
# Serial ATA devices
#

$(eval $(call KMOD_template,SATA_AHCI,sata-ahci,\
	$(MODULES_DIR)/kernel/drivers/ata/ahci \
,10))

#
# Ethernet network devices
# 

$(eval $(call KMOD_template,NE2K_PCI,ne2k-pci,\
	$(MODULES_DIR)/kernel/drivers/net/8390 \
	$(MODULES_DIR)/kernel/drivers/net/ne2k-pci \
,20))

$(eval $(call KMOD_template,8139CP,8139cp,\
	$(MODULES_DIR)/kernel/drivers/net/8139cp \
,20))

$(eval $(call KMOD_template,8139TOO,8139too,\
	$(MODULES_DIR)/kernel/drivers/net/8139too \
,20))

$(eval $(call KMOD_template,E100,e100,\
	$(MODULES_DIR)/kernel/drivers/net/e100 \
,20))

$(eval $(call KMOD_template,E1000,e1000,\
	$(MODULES_DIR)/kernel/drivers/net/e1000/e1000 \
,20))

$(eval $(call KMOD_template,SKY2,sky2,\
	$(MODULES_DIR)/kernel/drivers/net/sky2 \
,20))

# 
# Wireless network devices
#

$(eval $(call KMOD_template,MAC80211,mac80211,\
	$(MODULES_DIR)/kernel/net/wireless/cfg80211 \
	$(MODULES_DIR)/kernel/net/mac80211/mac80211 \
,15, kmod-crypto-aes kmod-crypto-arc4 kmod-crypto-ecb kmod-crc32))

$(eval $(call KMOD_template,ATH5K,ath5k,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/ath/ath \
	$(MODULES_DIR)/kernel/drivers/net/wireless/ath/ath5k/ath5k \
,20, kmod-led-class))

$(eval $(call KMOD_template,P54_COMMON,p54-common,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/p54/p54common \
,68))

$(eval $(call KMOD_template,RTL8187B,rtl8187b,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/rtl8187b/rtl8187b \
,70))

$(eval $(call KMOD_template,B43,b43,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/b43/b43 \
,70))

$(eval $(call KMOD_template,P54_USB,p54-usb,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/p54/p54usb \
,70))

$(eval $(call KMOD_template,RT2X00,rt2x00,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/rt2x00/rt2x00lib \
	$(MODULES_DIR)/kernel/drivers/net/wireless/rt2x00/rt2x00pci \
,17))

$(eval $(call KMOD_template,RT2400PCI,rt2400pci,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/rt2x00/rt2400pci \
,20, kmod-led-class kmod-rt2x00))

$(eval $(call KMOD_template,RT2500PCI,rt2500pci,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/rt2x00/rt2500pci \
,20, kmod-led-class kmod-rt2x00))

$(eval $(call KMOD_template,RT61PCI,rt61pci,\
	$(MODULES_DIR)/kernel/drivers/net/wireless/rt2x00/rt61pci \
,20, kmod-led-class kmod-rt2x00))

#
# Networking
#

$(eval $(call KMOD_template,ATM,atm,\
	$(MODULES_DIR)/kernel/net/atm/atm \
,50))

$(eval $(call KMOD_template,ATM_BR2684,atm-br2684,\
	$(MODULES_DIR)/kernel/net/atm/br2684 \
,51))

$(eval $(call KMOD_template,VLAN_8021Q,vlan-8021q,\
	$(MODULES_DIR)/kernel/net/8021q/8021q \
,5))

$(eval $(call KMOD_template,BRIDGE,bridge,\
	$(MODULES_DIR)/kernel/net/llc/llc \
	$(MODULES_DIR)/kernel/net/802/stp \
	$(MODULES_DIR)/kernel/net/bridge/bridge \
,10))

$(eval $(call KMOD_template,NET_IPGRE,net-ipgre,\
	$(MODULES_DIR)/kernel/net/ipv4/ip_gre \
,50))

$(eval $(call KMOD_template,INET_TUNNEL,inet-tunnel,\
	$(MODULES_DIR)/kernel/net/ipv4/tunnel4 \
,20))

$(eval $(call KMOD_template,NET_IPIP,net-ipip,\
	$(MODULES_DIR)/kernel/net/ipv4/ipip \
,60))

$(eval $(call KMOD_template,IPV6,ipv6,\
	$(MODULES_DIR)/kernel/net/ipv6/ipv6 \
,19))

$(eval $(call KMOD_template,IPV6_SIT,ipv6-sit,\
	$(MODULES_DIR)/kernel/net/ipv6/sit \
,25))

$(eval $(call KMOD_template,PPP,ppp,\
	$(MODULES_DIR)/kernel/drivers/net/slhc \
	$(MODULES_DIR)/kernel/drivers/net/ppp_generic \
	$(MODULES_DIR)/kernel/drivers/net/ppp_async \
,50))

$(eval $(call KMOD_template,MPPE,mppe,\
	$(MODULES_DIR)/kernel/drivers/net/ppp_mppe_mppc \
,55))

$(eval $(call KMOD_template,PPPOATM,pppoatm,\
	$(MODULES_DIR)/kernel/net/atm/pppoatm \
,60))

$(eval $(call KMOD_template,PPPOE,pppoe,\
	$(MODULES_DIR)/kernel/drivers/net/pppox \
	$(MODULES_DIR)/kernel/drivers/net/pppoe \
,60))

$(eval $(call KMOD_template,TUN,tun,\
	$(MODULES_DIR)/kernel/drivers/net/tun \
,20))

$(eval $(call KMOD_template,BONDING,bonding,\
	$(MODULES_DIR)/kernel/drivers/net/bonding/bonding \
,20))

#
# Traffic scheduling
#

$(eval $(call KMOD_template,NET_SCH_CBQ,net-sch-cbq,\
	$(MODULES_DIR)/kernel/net/sched/sch_cbq \
,40))

$(eval $(call KMOD_template,NET_SCH_HTB,net-sch-htb,\
	$(MODULES_DIR)/kernel/net/sched/sch_htb \
,40))

$(eval $(call KMOD_template,NET_SCH_HFSC,net-sch-hfsc,\
	$(MODULES_DIR)/kernel/net/sched/sch_hfsc \
,40))

$(eval $(call KMOD_template,NET_SCH_ATM,net-sch-atm,\
	$(MODULES_DIR)/kernel/net/sched/sch_atm \
,40))

$(eval $(call KMOD_template,NET_SCH_PRIO,net-sch-prio,\
	$(MODULES_DIR)/kernel/net/sched/sch_prio \
,40))

$(eval $(call KMOD_template,NET_SCH_RED,net-sch-red,\
	$(MODULES_DIR)/kernel/net/sched/sch_red \
,40))

$(eval $(call KMOD_template,NET_SCH_SFQ,net-sch-sfq,\
	$(MODULES_DIR)/kernel/net/sched/sch_sfq \
,40))

# busybox netapps crash, when module loaded
#$(eval $(call KMOD_template,NET_SCH_TEQL,net-sched-teql,\
#	$(MODULES_DIR)/kernel/net/sched/sch_teql \
#,40))

$(eval $(call KMOD_template,NET_SCH_TBF,net-sch-tbf,\
	$(MODULES_DIR)/kernel/net/sched/sch_tbf \
,40))

$(eval $(call KMOD_template,NET_SCH_GRED,net-sch-gred,\
	$(MODULES_DIR)/kernel/net/sched/sch_gred \
,40))

$(eval $(call KMOD_template,NET_SCH_DSMARK,net-sch-dsmark,\
	$(MODULES_DIR)/kernel/net/sched/sch_dsmark \
,40))

$(eval $(call KMOD_template,NET_SCH_INGRESS,net-sch-ingress,\
	$(MODULES_DIR)/kernel/net/sched/sch_ingress \
,40))

#
# classifications
#

$(eval $(call KMOD_template,NET_CLS_BASIC,net-cls-basic,\
	$(MODULES_DIR)/kernel/net/sched/cls_basic \
,40))

$(eval $(call KMOD_template,NET_CLS_TCINDEX,net-cls-tcindex,\
	$(MODULES_DIR)/kernel/net/sched/cls_tcindex \
,40))

$(eval $(call KMOD_template,NET_CLS_ROUTE4,net-cls-route4,\
	$(MODULES_DIR)/kernel/net/sched/cls_route \
,40))

$(eval $(call KMOD_template,NET_CLS_FW,net-cls-fw,\
	$(MODULES_DIR)/kernel/net/sched/cls_fw \
,40))

$(eval $(call KMOD_template,NET_CLS_U32,net-cls-u32,\
	$(MODULES_DIR)/kernel/net/sched/cls_u32 \
,40))

#
# actions
#

$(eval $(call KMOD_template,NET_ACT_POLICE,net-act-police,\
	$(MODULES_DIR)/kernel/net/sched/act_police \
,45))

$(eval $(call KMOD_template,NET_ACT_GACT,net-act-gact,\
	$(MODULES_DIR)/kernel/net/sched/act_gact \
,45))

$(eval $(call KMOD_template,NET_ACT_MIRRED,net-act-mirred,\
	$(MODULES_DIR)/kernel/net/sched/act_mirred \
,45))

$(eval $(call KMOD_template,NET_ACT_IPT,net-act-ipt,\
	$(MODULES_DIR)/kernel/net/sched/act_ipt \
,45))

$(eval $(call KMOD_template,NET_ACT_PEDIT,net-act-pedit,\
	$(MODULES_DIR)/kernel/net/sched/act_pedit \
,45))

#
# IPsec 
#

$(eval $(call KMOD_template,NET_KEY,net-key,\
	$(MODULES_DIR)/kernel/net/key/af_key \
,60))

$(eval $(call KMOD_template,XFRM_USER,xfrm-user,\
	$(MODULES_DIR)/kernel/net/xfrm/xfrm_user \
,61))

$(eval $(call KMOD_template,INET_AH,inet-ah,\
	$(MODULES_DIR)/kernel/net/ipv4/ah4 \
,65))

$(eval $(call KMOD_template,INET_ESP,inet-esp,\
	$(MODULES_DIR)/kernel/net/ipv4/esp4 \
,65))

$(eval $(call KMOD_template,INET_IPCOMP,inet-ipcomp,\
	$(MODULES_DIR)/kernel/net/ipv4/xfrm4_tunnel \
	$(MODULES_DIR)/kernel/net/xfrm/xfrm_ipcomp \
	$(MODULES_DIR)/kernel/net/ipv4/ipcomp \
,70))

$(eval $(call KMOD_template,INET_XFRM_MODE_TRANSPORT,inet-xfrm-mode-transport,\
	$(MODULES_DIR)/kernel/net/ipv4/xfrm4_mode_transport \
,75))

$(eval $(call KMOD_template,INET_XFRM_MODE_TUNNEL,inet-xfrm-mode-tunnel,\
	$(MODULES_DIR)/kernel/net/ipv4/xfrm4_mode_tunnel \
,75))

$(eval $(call KMOD_template,INET_XFRM_MODE_BEET,inet-xfrm-mode-beet,\
	$(MODULES_DIR)/kernel/net/ipv4/xfrm4_mode_beet \
,75))

##
## Filtering / Firewalling
##

#
# Ethernet Bridging firewall
#

$(eval $(call KMOD_template,BRIDGE_NF_EBTABLES,bridge-nf-ebtables,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebtables \
,55))

$(eval $(call KMOD_template,BRIDGE_EBT_BROUTE,bridge-ebt-broute,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebtable_broute \
,60))

$(eval $(call KMOD_template,BRIDGE_EBT_T_FILTER,bridge-ebt-t-filter,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebtable_filter \
,60))

$(eval $(call KMOD_template,BRIDGE_EBT_T_NAT,bridge-ebt-t-nat,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebtable_nat \
,60))

$(eval $(call KMOD_template,BRIDGE_EBT_802_3,bridge-ebt-802-3,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebt_802_3 \
,65))

$(eval $(call KMOD_template,BRIDGE_EBT_AMONG,bridge-ebt-among,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebt_among \
,65))

$(eval $(call KMOD_template,BRIDGE_EBT_ARP,bridge-ebt-arp,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebt_arpreply \
,65))

$(eval $(call KMOD_template,BRIDGE_EBT_IP,bridge-ebt-ip,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebt_ip \
,65))

$(eval $(call KMOD_template,BRIDGE_EBT_REDIRECT,bridge-ebt-redirect,\
	$(MODULES_DIR)/kernel/net/bridge/netfilter/ebt_redirect \
,65))

#
# Netfilter Core
#

$(eval $(call KMOD_template,NETFILTER_XT_TARGET_CLASSIFY,netfiler-xt-target-classify,\
	$(MODULES_DIR)/kernel/net/netfilter/xt_CLASSIFY \
,50))

ifeq ($(KERNEL_VERSION),2.6.35.4)
CONNMARK:=xt_connmark
MARK:=xt_mark
else
CONNMARK:=xt_CONNMARK
MARK:=xt_MARK
endif

$(eval $(call KMOD_template,NETFILTER_XT_TARGET_CONNMARK,netfilter-xt-target-connmark,\
	$(MODULES_DIR)/kernel/net/netfilter/$(CONNMARK) \
,50))

$(eval $(call KMOD_template,NETFILTER_XT_TARGET_MARK,netfilter-xt-target-mark,\
	$(MODULES_DIR)/kernel/net/netfilter/$(MARK) \
,50))

$(eval $(call KMOD_template,NETFILTER_XT_TARGET_NFQUEUE,netfilter-xt-target-nfqueue,\
	$(MODULES_DIR)/kernel/net/netfilter/xt_NFQUEUE \
,50))

$(eval $(call KMOD_template,NETFILTER_XT_TARGET_TCPMSS,netfilter-xt-target-tcpmss,\
	$(MODULES_DIR)/kernel/net/netfilter/xt_TCPMSS \
,50))

$(eval $(call KMOD_template,NETFILTER_XT_TARGET_NOTRACK,netfilter-xt-target-notrack,\
	$(MODULES_DIR)/kernel/net/netfilter/xt_NOTRACK \
,50))

#
# IP: Netfilter
#

$(eval $(call KMOD_template,NF_CONNTRACK,nf-conntrack,\
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack \
,45))

$(eval $(call KMOD_template,NF_CONNTRACK_IPV4,nf-conntrack-ipv4,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_defrag_ipv4 \
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_conntrack_ipv4 \
,50))

$(eval $(call KMOD_template,NF_NAT,nf-nat,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat \
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/iptable_nat \
,50))

$(eval $(call KMOD_template,NF_CONNTRACK_FTP,nf-conntrack-ftp,\
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_ftp \
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat_ftp \
,55))

$(eval $(call KMOD_template,NF_CONNTRACK_IRC,nf-conntrack-irc,\
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_irc \
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat_irc \
,55))

$(eval $(call KMOD_template,NF_CONNTRACK_NETBIOS_NS,nf-conntrack-netbios-ns,\
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_netbios_ns \
,55))

$(eval $(call KMOD_template,NF_CONNTRACK_TFTP,nf-conntrack-tftp,\
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_tftp \
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat_tftp \
,55))

#$(eval $(call KMOD_template,NF_CONNTRACK_RTSP,nf-conntrack-rtsp,\
#	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_rtsp \
#	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat_rtsp \
#,55))

# broken
#$(eval $(call KMOD_template,NF_CONNTRACK_AMANDA,nf-conntrack-amanda,\
#	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_amanda \
#	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat_amanda \
#,55))

$(eval $(call KMOD_template,NF_CONNTRACK_PPTP,nf-conntrack-pptp,\
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_proto_gre \
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_pptp \
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat_pptp \
,55))

$(eval $(call KMOD_template,NF_CONNTRACK_H323,nf-conntrack-h323,\
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_h323 \
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat_h323 \
,55))

$(eval $(call KMOD_template,NF_CONNTRACK_SIP,nf-conntrack-sip,\
	$(MODULES_DIR)/kernel/net/netfilter/nf_conntrack_sip \
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/nf_nat_sip \
,55))

$(eval $(call KMOD_template,IP_NF_IPTABLES,ip-nf-iptables,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ip_tables \
,50))

$(eval $(call KMOD_template,IP_NF_MATCH_IPRANGE,ip-nf-match-iprange,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_iprange \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_TOS,ip-nf-match-tos,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_tos \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_RECENT,ip-nf-match-recent,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_recent \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_ECN,ip-nf-match-ecn,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_ecn \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_AH,ip-nf-match-ah,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_ah \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_TTL,ip-nf-match-ttl,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_ttl \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_OWNER,ip-nf-match-owner,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_owner \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_ADDRTYPE,ip-nf-match-addrtype,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_addrtype \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_HASHLIMIT,ip-nf-match-hashlimit,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_hashlimit \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_STATE,ip-nf-match-state,\
	$(MODULES_DIR)/kernel/net/netfilter/xt_state \
,55))

$(eval $(call KMOD_template,IP_NF_MATCH_MULTIPORT,ip-nf-match-multiport,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_multiport \
,55))

#
# Filtering
#

$(eval $(call KMOD_template,IP_NF_FILTER,ip-nf-filter,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/iptable_filter \
,55))

$(eval $(call KMOD_template,IP_NF_TARGET_REJECT,ip-nf-target-reject,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_REJECT \
,60))

$(eval $(call KMOD_template,IP_NF_TARGET_LOG,ip-nf-target-log,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_LOG \
,60))

$(eval $(call KMOD_template,IP_NF_TARGET_ULOG,ip-nf-target-ulog,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_ULOG \
,60))

$(eval $(call KMOD_template,IP_NF_TARGET_TCPMSS,ip-nf-target-tcpmss,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_TCPMSS \
,60))

$(eval $(call KMOD_template,IP_NF_TARGET_MASQUERADE,ip-nf-target-masquerade,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_MASQUERADE \
,65))

$(eval $(call KMOD_template,IP_NF_TARGET_REDIRECT,ip-nf-target-redirect,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_REDIRECT \
,65))

$(eval $(call KMOD_template,IP_NF_TARGET_NETMAP,ip-nf-target-netmap,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_NETMAP \
,65))

#
# Mangle
#

$(eval $(call KMOD_template,IP_NF_MANGLE,ip-nf-mangle,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/iptable_mangle \
,60))

$(eval $(call KMOD_template,IP_NF_TARGET_TOS,ip-nf-target-tos,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_TOS \
,65))

$(eval $(call KMOD_template,IP_NF_TARGET_ECN,ip-nf-target-ecn,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_ECN \
,65))

$(eval $(call KMOD_template,IP_NF_TARGET_TTL,ip-nf-target-ttl,\
	$(MODULES_DIR)/kernel/net/ipv4/netfilter/ipt_TTL \
,65))

#
# IPv6: Netfilter
#

$(eval $(call KMOD_template,NF_CONNTRACK_IPV6,nf-conntrack-ipv6,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/nf_conntrack_ipv6 \
,50))

$(eval $(call KMOD_template,IP6_NF_IPTABLES,ip6-nf-iptables,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6_tables \
,50))

$(eval $(call KMOD_template,IP6_NF_MATCH_AH,ip6-nf-match-ah,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_ah \
,55))

$(eval $(call KMOD_template,IP6_NF_MATCH_EUI64,ip6-nf-match-eui64,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_eui64 \
,55))

$(eval $(call KMOD_template,IP6_NF_MATCH_FRAG,ip6-nf-match-frag,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_frag \
,55))

$(eval $(call KMOD_template,IP6_NF_MATCH_OPTS,ip6-nf-match-opts,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_hbh \
,55))

$(eval $(call KMOD_template,IP6_NF_MATCH_IPV6HEADER,ip6-nf-match-ipv6header,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_ipv6header \
,55))

$(eval $(call KMOD_template,IP6_NF_MATCH_MH,ip6-nf-match-mh,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_mh \
,55))

$(eval $(call KMOD_template,IP6_NF_MATCH_RT,ip6-nf-match-rt,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_rt \
,55))

$(eval $(call KMOD_template,IP6_NF_TARGET_LOG,ip6-nf-target-log,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_LOG \
,55))

#
# IPv6: Filtering
#

$(eval $(call KMOD_template,IP6_NF_FILTER,ip6-nf-filter,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6table_filter \
,55))

$(eval $(call KMOD_template,IP6_NF_TARGET_REJECT,ip6-nf-target-reject,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6t_REJECT \
,60))

#
# IPv6: Mangle
#

$(eval $(call KMOD_template,IP6_NF_MANGLE,ip6-nf-mangle,\
	$(MODULES_DIR)/kernel/net/ipv6/netfilter/ip6table_mangle \
,60))

#
# IPVS
#

IPVSPATH=$(MODULES_DIR)/kernel/net/netfilter/ipvs

$(eval $(call KMOD_template,IP_VS,ip-vs,\
	$(IPVSPATH)/ip_vs \
,55))

$(eval $(call KMOD_template,IP_VS_RR,ip-vs-rr,\
	$(IPVSPATH)/ip_vs_rr \
,55))

$(eval $(call KMOD_template,IP_VS_WRR,ip-vs-wrr,\
	$(IPVSPATH)/ip_vs_wrr \
,55))

$(eval $(call KMOD_template,IP_VS_LC,ip-vs-lc,\
	$(IPVSPATH)/ip_vs_lc \
,55))

$(eval $(call KMOD_template,IP_VS_WLC,ip-vs-wlc,\
	$(IPVSPATH)/ip_vs_wlc \
,55))

$(eval $(call KMOD_template,IP_VS_LBLC,ip-vs-lblc,\
	$(IPVSPATH)/ip_vs_lblc \
,55))

$(eval $(call KMOD_template,IP_VS_LBLCR,ip-vs-lblcr,\
	$(IPVSPATH)/ip_vs_lblcr \
,55))

$(eval $(call KMOD_template,IP_VS_DH,ip-vs-dh,\
	$(IPVSPATH)/ip_vs_dh \
,55))

$(eval $(call KMOD_template,IP_VS_SH,ip-vs-sh,\
	$(IPVSPATH)/ip_vs_sh \
,55))

$(eval $(call KMOD_template,IP_VS_SED,ip-vs-sed,\
	$(IPVSPATH)/ip_vs_sed \
,55))

$(eval $(call KMOD_template,IP_VS_NQ,ip-vs-nq,\
	$(IPVSPATH)/ip_vs_nq \
,55))

$(eval $(call KMOD_template,IP_VS_FTP,ip-vs-ftp,\
	$(IPVSPATH)/ip_vs_ftp \
,55))

#
# Block devices
#

$(eval $(call KMOD_template,BLK_DEV_LOOP,blk-dev-loop,\
    $(MODULES_DIR)/kernel/drivers/block/loop \
,20))

$(eval $(call KMOD_template,BLK_DEV_NBD,blk-dev-nbd,\
    $(MODULES_DIR)/kernel/drivers/block/nbd \
,20))

$(eval $(call KMOD_template,SCSI,scsi,\
    $(MODULES_DIR)/kernel/drivers/scsi/scsi_wait_scan \
    $(MODULES_DIR)/kernel/drivers/scsi/scsi_mod \
,20))

$(eval $(call KMOD_template,BLK_DEV_SD,blk-dev-sd,\
    $(MODULES_DIR)/kernel/drivers/scsi/sd_mod \
,25))

$(eval $(call KMOD_template,BLK_DEV_SR,blk-dev-sr,\
    $(MODULES_DIR)/kernel/drivers/cdrom/cdrom \
    $(MODULES_DIR)/kernel/drivers/scsi/sr_mod \
,25))

#
# RAID
#

$(eval $(call KMOD_template,BLK_DEV_MD,blk-dev-md,\
    $(MODULES_DIR)/kernel/drivers/md/md-mod \
,30))

$(eval $(call KMOD_template,MD_RAID0,md-raid0,\
    $(MODULES_DIR)/kernel/drivers/md/raid0 \
,35))

$(eval $(call KMOD_template,MD_RAID1,md-raid1,\
    $(MODULES_DIR)/kernel/drivers/md/raid1 \
,35))

$(eval $(call KMOD_template,MD_RAID456,md-raid456,\
    $(MODULES_DIR)/kernel/crypto/xor \
    $(MODULES_DIR)/kernel/crypto/async_tx/async_tx \
    $(MODULES_DIR)/kernel/crypto/async_tx/async_xor \
    $(MODULES_DIR)/kernel/crypto/async_tx/async_memcpy \
    $(MODULES_DIR)/kernel/drivers/md/raid6_pq \
    $(MODULES_DIR)/kernel/crypto/async_tx/async_raid6_recov \
    $(MODULES_DIR)/kernel/drivers/md/raid456 \
,35))

#
# Device Mapper
#

$(eval $(call KMOD_template,BLK_DEV_DM,blk-dev-dm,\
    $(MODULES_DIR)/kernel/drivers/md/dm-mod \
,35))

$(eval $(call KMOD_template,DM_CRYPT,dm-crypt,\
    $(MODULES_DIR)/kernel/drivers/md/dm-crypt \
,40))

$(eval $(call KMOD_template,DM_MIRROR,dm-mirror,\
    $(MODULES_DIR)/kernel/drivers/md/dm-log \
    $(MODULES_DIR)/kernel/drivers/md/dm-region-hash \
    $(MODULES_DIR)/kernel/drivers/md/dm-mirror \
,40))

$(eval $(call KMOD_template,DM_SNAPSHOT,dm-snapshot,\
    $(MODULES_DIR)/kernel/drivers/md/dm-snapshot \
,40))

#
# Crypto
#

$(eval $(call KMOD_template,CRYPTO_DEV_GEODE,crypto-dev-geode,\
    $(MODULES_DIR)/kernel/drivers/crypto/geode-aes \
,20))

$(eval $(call KMOD_template,CRYPTO_ALGAPI,crypto-algapi,\
    $(MODULES_DIR)/kernel/crypto/crypto_algapi \
    $(MODULES_DIR)/kernel/crypto/pcompress \
,02))

$(eval $(call KMOD_template,CRYPTO_AEAD,crypto-aead,\
    $(MODULES_DIR)/kernel/crypto/aead \
,03))

$(eval $(call KMOD_template,CRYPTO_HASH,crypto-hash,\
    $(MODULES_DIR)/kernel/crypto/crypto_hash \
,04))

$(eval $(call KMOD_template,CRYPTO_BLKCIPHER,crypto-blkcipher,\
    $(MODULES_DIR)/kernel/crypto/crypto_wq \
    $(MODULES_DIR)/kernel/crypto/crypto_blkcipher \
,05))

$(eval $(call KMOD_template,CRYPTO_RNG2,crypto-rng2,\
    $(MODULES_DIR)/kernel/crypto/rng \
    $(MODULES_DIR)/kernel/crypto/krng \
,06))

$(eval $(call KMOD_template,CRYPTO_MANAGER,crypto-manager,\
    $(MODULES_DIR)/kernel/crypto/cryptomgr \
    $(MODULES_DIR)/kernel/crypto/eseqiv \
    $(MODULES_DIR)/kernel/crypto/chainiv \
,07))

$(eval $(call KMOD_template,CRYPTO_AUTHENC,crypto-authenc,\
    $(MODULES_DIR)/kernel/crypto/authenc \
,11))

$(eval $(call KMOD_template,CRYPTO_HMAC,crypto-hmac,\
    $(MODULES_DIR)/kernel/crypto/hmac \
,11))

$(eval $(call KMOD_template,CRYPTO_XCBC,crypto-xcbc,\
    $(MODULES_DIR)/kernel/crypto/xcbc \
,11))

$(eval $(call KMOD_template,CRYPTO_NULL,crypto-null,\
    $(MODULES_DIR)/kernel/crypto/crypto_null \
,11))

$(eval $(call KMOD_template,CRYPTO_MD4,crypto-md4,\
    $(MODULES_DIR)/kernel/crypto/md4 \
,11))

$(eval $(call KMOD_template,CRYPTO_MD5,crypto-md5,\
    $(MODULES_DIR)/kernel/crypto/md5 \
,11))

$(eval $(call KMOD_template,CRYPTO_SHA1,crypto-sha1,\
    $(MODULES_DIR)/kernel/crypto/sha1_generic \
,11))

$(eval $(call KMOD_template,CRYPTO_SHA256,crypto-sha256,\
    $(MODULES_DIR)/kernel/crypto/sha256_generic \
,11))

$(eval $(call KMOD_template,CRYPTO_SHA512,crypto-sha512,\
    $(MODULES_DIR)/kernel/crypto/sha512_generic \
,11))

$(eval $(call KMOD_template,CRYPTO_WP512,crypto-wp512,\
    $(MODULES_DIR)/kernel/crypto/wp512 \
,11))

$(eval $(call KMOD_template,CRYPTO_TGR192,crypto-tgr192,\
    $(MODULES_DIR)/kernel/crypto/tgr192 \
,11))

$(eval $(call KMOD_template,CRYPTO_SEQIV,crypto-seqiv,\
    $(MODULES_DIR)/kernel/crypto/seqiv \
,5))

$(eval $(call KMOD_template,CRYPTO_CTR,crypto-ctr,\
    $(MODULES_DIR)/kernel/crypto/ctr \
,10))

$(eval $(call KMOD_template,CRYPTO_CCM,crypto-ccm,\
    $(MODULES_DIR)/kernel/crypto/ccm \
,10))

$(eval $(call KMOD_template,CRYPTO_ECB,crypto-ecb,\
    $(MODULES_DIR)/kernel/crypto/ecb \
,10))

$(eval $(call KMOD_template,CRYPTO_CBC,crypto-cbc,\
    $(MODULES_DIR)/kernel/crypto/cbc \
,10))

$(eval $(call KMOD_template,CRYPTO_DES,crypto-des,\
    $(MODULES_DIR)/kernel/crypto/des_generic \
,10))

$(eval $(call KMOD_template,CRYPTO_BLOWFISH,crypto-blowfish,\
    $(MODULES_DIR)/kernel/crypto/blowfish \
,11))

$(eval $(call KMOD_template,CRYPTO_TWOFISH,crypto-twofish,\
    $(MODULES_DIR)/kernel/crypto/twofish_common \
    $(MODULES_DIR)/kernel/crypto/twofish \
,11))

$(eval $(call KMOD_template,CRYPTO_TWOFISH_586,crypto-twofish-586,\
    $(MODULES_DIR)/kernel/arch/x86/crypto/twofish-i586 \
,12))

$(eval $(call KMOD_template,CRYPTO_SERPENT,crypto-serpent,\
    $(MODULES_DIR)/kernel/crypto/serpent \
,11))

$(eval $(call KMOD_template,CRYPTO_AES,crypto-aes,\
    $(MODULES_DIR)/kernel/crypto/aes_generic \
,10))

$(eval $(call KMOD_template,CRYPTO_AES_586,crypto-aes-586,\
    $(MODULES_DIR)/kernel/arch/x86/crypto/aes-i586 \
,11))

$(eval $(call KMOD_template,CRYPTO_CAST5,crypto-cast5,\
    $(MODULES_DIR)/kernel/crypto/cast5 \
,11))

$(eval $(call KMOD_template,CRYPTO_CAST6,crypto-cast6,\
    $(MODULES_DIR)/kernel/crypto/cast6 \
,11))

$(eval $(call KMOD_template,CRYPTO_TEA,crypto-tea,\
    $(MODULES_DIR)/kernel/crypto/tea \
,11))

$(eval $(call KMOD_template,CRYPTO_ARC4,crypto-arc4,\
    $(MODULES_DIR)/kernel/crypto/arc4 \
,11))

$(eval $(call KMOD_template,CRYPTO_KHAZAD,crypto-khazad,\
    $(MODULES_DIR)/kernel/crypto/khazad \
,11))

$(eval $(call KMOD_template,CRYPTO_ANUBIS,crypto-anubis,\
    $(MODULES_DIR)/kernel/crypto/anubis \
,11))

$(eval $(call KMOD_template,CRYPTO_CAMELLIA,crypto-camellia,\
    $(MODULES_DIR)/kernel/crypto/camellia \
,11))

$(eval $(call KMOD_template,CRYPTO_FCRYPT,crypto-fcrypt,\
    $(MODULES_DIR)/kernel/crypto/fcrypt \
,11))

ZLIB:=lib/zlib_deflate/zlib_deflate
ifeq ($(ADK_LINUX_CRIS_FOXBOARD),)
ifeq ($(ADK_LINUX_MIPS_AG241),)
ZLIB+=lib/zlib_inflate/zlib_inflate
endif
endif

$(eval $(call KMOD_template,CRYPTO_DEFLATE,crypto-deflate,\
    $(foreach mod, $(ZLIB),$(MODULES_DIR)/kernel/$(mod)) \
    $(MODULES_DIR)/kernel/crypto/deflate \
,10))

$(eval $(call KMOD_template,CRYPTO_LZO,crypto-lzo,\
    $(MODULES_DIR)/kernel/lib/lzo/lzo_compress \
    $(MODULES_DIR)/kernel/lib/lzo/lzo_decompress \
    $(MODULES_DIR)/kernel/crypto/lzo \
,10))

$(eval $(call KMOD_template,CRYPTO_MICHAEL_MIC,crypto-michael-mic,\
    $(MODULES_DIR)/kernel/crypto/michael_mic \
,11))

$(eval $(call KMOD_template,CRYPTO_CRC32C,crypto-crc32c,\
    $(MODULES_DIR)/kernel/crypto/crc32c \
,11))

$(eval $(call KMOD_template,OCF_CRYPTOSOFT,ocf-cryptosoft,\
    ${MODULES_DIR}/kernel/crypto/ocf/cryptosoft \
,12))

$(eval $(call KMOD_template,OCF_SAFE,ocf-safe,\
    ${MODULES_DIR}/kernel/crypto/ocf/safe/safe \
,12))

$(eval $(call KMOD_template,OCF_IXP4XX,ocf-ixp4xx,\
    ${MODULES_DIR}/kernel/crypto/ocf/ixp4xx/ixp4xx \
,12))

$(eval $(call KMOD_template,OCF_HIFN,ocf-hifn,\
    ${MODULES_DIR}/kernel/crypto/ocf/hifn/hifn7751 \
,12))

$(eval $(call KMOD_template,OCF_TALITOS,ocf-talitos,\
    ${MODULES_DIR}/kernel/crypto/ocf/talitos/talitos \
,12))

#
# Filesystems
#

$(eval $(call KMOD_template,AUFS_FS,aufs-fs,\
	$(MODULES_DIR)/kernel/fs/aufs/aufs \
,30))

$(eval $(call KMOD_template,CIFS,cifs,\
	$(MODULES_DIR)/kernel/fs/cifs/cifs \
,30))

$(eval $(call KMOD_template,CODA_FS,coda-fs,\
	$(MODULES_DIR)/kernel/fs/coda/coda \
,30))

ifneq ($(ADK_KERNEL_EXT2_FS),y)
$(eval $(call KMOD_template,EXT2_FS,ext2-fs,\
	$(MODULES_DIR)/kernel/fs/ext2/ext2 \
,30))
endif

$(eval $(call KMOD_template,EXT3_FS,ext3-fs,\
	$(MODULES_DIR)/kernel/fs/jbd/jbd \
	$(MODULES_DIR)/kernel/fs/ext3/ext3 \
,30))

$(eval $(call KMOD_template,EXT4_FS,ext4-fs,\
	$(MODULES_DIR)/kernel/fs/mbcache \
	$(MODULES_DIR)/kernel/fs/jbd2/jbd2 \
	$(MODULES_DIR)/kernel/fs/ext4/ext4 \
,30))

$(eval $(call KMOD_template,FUSE_FS,fuse-fs,\
	$(MODULES_DIR)/kernel/fs/fuse/fuse \
,30))

$(eval $(call KMOD_template,HFSPLUS_FS,hfsplus-fs,\
	$(MODULES_DIR)/kernel/fs/hfsplus/hfsplus \
,30))

$(eval $(call KMOD_template,SUNRPC,sunrpc,\
	$(MODULES_DIR)/kernel/net/sunrpc/sunrpc \
,24))

$(eval $(call KMOD_template,SUNRPC_GSS,sunrpc-gss,\
	$(MODULES_DIR)/kernel/net/sunrpc/auth_gss/auth_rpcgss \
,25))

$(eval $(call KMOD_template,RPCSEC_GSS_KRB5,rpcsec-gss-krb5,\
	$(MODULES_DIR)/kernel/net/sunrpc/auth_gss/rpcsec_gss_krb5 \
,26))

$(eval $(call KMOD_template,LOCKD,lockd,\
	$(MODULES_DIR)/kernel/fs/lockd/lockd \
,27))

ifneq ($(ADK_KERNEL_NFS_FS),y)
$(eval $(call KMOD_template,NFS_FS,nfs-fs,\
	$(MODULES_DIR)/kernel/fs/nfs/nfs \
,30))
endif

$(eval $(call KMOD_template,EXPORTFS,exportfs,\
	$(MODULES_DIR)/kernel/fs/exportfs/exportfs \
,20))

$(eval $(call KMOD_template,NFSD,nfsd,\
        $(MODULES_DIR)/kernel/fs/nfsd/nfsd \
,30))

$(eval $(call KMOD_template,NTFS_FS,ntfs-fs,\
	$(MODULES_DIR)/kernel/fs/ntfs/ntfs \
,30))

$(eval $(call KMOD_template,VFAT_FS,vfat-fs,\
	$(MODULES_DIR)/kernel/fs/fat/fat \
	$(MODULES_DIR)/kernel/fs/fat/vfat \
,30))

$(eval $(call KMOD_template,XFS_FS,xfs-fs,\
	$(MODULES_DIR)/kernel/fs/xfs/xfs \
,30))

$(eval $(call KMOD_template,YAFFS_FS,yaffs-fs,\
	$(MODULES_DIR)/kernel/fs/yaffs2/yaffs \
,30))

$(eval $(call KMOD_template,REISERFS_FS,reiserfs-fs,\
	$(MODULES_DIR)/kernel/fs/reiserfs/reiserfs \
,30))

$(eval $(call KMOD_template,ISO9660_FS,iso9660-fs,\
	$(MODULES_DIR)/kernel/fs/isofs/isofs \
,30))

$(eval $(call KMOD_template,UDF_FS,udf-fs,\
	$(MODULES_DIR)/kernel/fs/udf/udf \
,30))

#
# Multimedia
#

$(eval $(call KMOD_template,SOUND,sound,\
	$(MODULES_DIR)/kernel/sound/soundcore \
,30))

$(eval $(call KMOD_template,SND,snd,\
	$(MODULES_DIR)/kernel/sound/core/snd-page-alloc \
	$(MODULES_DIR)/kernel/sound/core/snd \
	$(MODULES_DIR)/kernel/sound/core/snd-timer \
	$(MODULES_DIR)/kernel/sound/core/snd-pcm \
,40))

$(eval $(call KMOD_template,SND_RAWMIDI,snd-rawmidi,\
	$(MODULES_DIR)/kernel/sound/core/snd-hwdep \
	$(MODULES_DIR)/kernel/sound/core/snd-rawmidi \
,41))

$(eval $(call KMOD_template,SND_OSSEMUL,snd-ossemul,\
	$(MODULES_DIR)/kernel/sound/core/oss/snd-mixer-oss \
	$(MODULES_DIR)/kernel/sound/core/oss/snd-pcm-oss \
,45))

$(eval $(call KMOD_template,SND_AC97_CODEC,snd-ac97-codec,\
	$(MODULES_DIR)/kernel/sound/ac97_bus \
	$(MODULES_DIR)/kernel/sound/pci/ac97/snd-ac97-codec \
,50))

$(eval $(call KMOD_template,SND_VIA82XX,snd-via82xx,\
	$(MODULES_DIR)/kernel/sound/drivers/mpu401/snd-mpu401-uart \
	$(MODULES_DIR)/kernel/sound/pci/snd-via82xx \
,55))

$(eval $(call KMOD_template,SND_ENS1370,snd-ens1370,\
	$(MODULES_DIR)/kernel/sound/pci/snd-ens1370 \
,55))

$(eval $(call KMOD_template,SND_CS5535AUDIO,sound-cs5535audio,\
	$(MODULES_DIR)/kernel/sound/pci/cs5535audio/snd-cs5535audio \
,55))

V4L_COMPAT:=drivers/media/video/v4l1-compat
ifeq ($(ADK_LINUX_64),y)
V4L_COMPAT+=drivers/media/video/v4l2-compat-ioctl32
endif

$(eval $(call KMOD_template,VIDEO_DEV,video-dev,\
	$(foreach mod, $(V4L_COMPAT),$(MODULES_DIR)/kernel/$(mod)) \
	$(MODULES_DIR)/kernel/drivers/media/video/videodev \
,65))

$(eval $(call KMOD_template,USB_VIDEO_CLASS,usb-video-class,\
	$(MODULES_DIR)/kernel/drivers/media/video/uvc/uvcvideo \
,70))

$(eval $(call KMOD_template,PWC,pwc,\
	$(MODULES_DIR)/kernel/drivers/usb/pwc \
,70))

#
# PCMCIA/CardBus
#

$(eval $(call KMOD_template,PCCARD,pccard,\
	$(MODULES_DIR)/kernel/drivers/pcmcia/pcmcia_core \
,40))

$(eval $(call KMOD_template,YENTA,yenta,\
	$(MODULES_DIR)/kernel/drivers/pcmcia/rsrc_nonstatic \
	$(MODULES_DIR)/kernel/drivers/pcmcia/yenta_socket \
,50))

$(eval $(call KMOD_template,PCMCIA,pcmcia,\
	$(MODULES_DIR)/kernel/drivers/pcmcia/pcmcia \
,60))

$(eval $(call KMOD_template,SERIAL_8250_CS,serial-8250-cs,\
	$(MODULES_DIR)/kernel/drivers/serial/serial_cs \
,70))

#
# Input
#

$(eval $(call KMOD_template,KEYBOARD_ATKBD,keyboard-atkbd,\
	$(MODULES_DIR)/kernel/drivers/input/keyboard/atkbd \
,45))

$(eval $(call KMOD_template,INPUT_MOUSEDEV,input-mousedev,\
	$(MODULES_DIR)/kernel/drivers/input/mousedev \
,45))

$(eval $(call KMOD_template,INPUT_EVDEV,input-evdev,\
	$(MODULES_DIR)/kernel/drivers/input/evdev \
,45))

#
# USB
#

ifeq ($(ADK_LINUX_CRIS_FOXBOARD),)
$(eval $(call KMOD_template,USB,usb,\
	$(MODULES_DIR)/kernel/drivers/usb/core/usbcore \
,50))
endif

$(eval $(call KMOD_template,USB_OHCI_HCD,usb-ohci-hcd,\
	$(MODULES_DIR)/kernel/drivers/usb/host/ohci-hcd \
,60))

$(eval $(call KMOD_template,USB_UHCI_HCD,usb-uhci-hcd,\
	$(MODULES_DIR)/kernel/drivers/usb/host/uhci-hcd \
,60))

$(eval $(call KMOD_template,USB_EHCI_HCD,usb-ehci-hcd,\
	$(MODULES_DIR)/kernel/drivers/usb/host/ehci-hcd \
,60))

$(eval $(call KMOD_template,USB_ACM,usb-acm,\
	$(MODULES_DIR)/kernel/drivers/usb/class/cdc-acm \
,70))

$(eval $(call KMOD_template,USB_HID,usb-hid,\
	$(MODULES_DIR)/kernel/drivers/hid/usbhid/usbhid \
,70))

$(eval $(call KMOD_template,USB_PRINTER,usb-printer,\
	$(MODULES_DIR)/kernel/drivers/usb/class/usblp \
,70))

$(eval $(call KMOD_template,USB_SERIAL,usb-serial,\
	$(MODULES_DIR)/kernel/drivers/usb/serial/usbserial \
,70))

$(eval $(call KMOD_template,USB_SERIAL_BELKIN,usb-serial-belkin,\
	$(MODULES_DIR)/kernel/drivers/usb/serial/belkin_sa \
,71))

$(eval $(call KMOD_template,USB_SERIAL_FTDI_SIO,usb-serial-ftdi-sio,\
	$(MODULES_DIR)/kernel/drivers/usb/serial/ftdi_sio \
,71))

$(eval $(call KMOD_template,USB_SERIAL_MCT_U232,usb-serial-mct-u232,\
	$(MODULES_DIR)/kernel/drivers/usb/serial/mct_u232 \
,71))

$(eval $(call KMOD_template,USB_SERIAL_PL2303,usb-serial-pl2303,\
	$(MODULES_DIR)/kernel/drivers/usb/serial/pl2303 \
,71))

$(eval $(call KMOD_template,USB_SERIAL_VISOR,usb-serial-visor,\
	$(MODULES_DIR)/kernel/drivers/usb/serial/visor \
,71))

$(eval $(call KMOD_template,USB_STORAGE,usb-storage,\
	$(MODULES_DIR)/kernel/drivers/usb/storage/usb-storage \
,75))

$(eval $(call KMOD_template,USB_PEGASUS,usb-pegasus,\
	$(MODULES_DIR)/kernel/drivers/net/usb/pegasus \
,75))

$(eval $(call KMOD_template,USB_HSO,usb-hso,\
	$(MODULES_DIR)/kernel/drivers/net/usb/hso \
,75))

ifeq ($(KERNEL_VERSION),2.6.35.4)
SNDUSB:=snd-usbmidi-lib
else
SNDUSB:=snd-usb-lib
endif

$(eval $(call KMOD_template,SND_USB_AUDIO,snd-usb-audio,\
	$(MODULES_DIR)/kernel/sound/usb/$(SNDUSB) \
	$(MODULES_DIR)/kernel/sound/usb/snd-usb-audio \
,75))

#
# Bluetooth
#

$(eval $(call KMOD_template,BT,bt,\
	$(MODULES_DIR)/kernel/net/bluetooth/bluetooth \
,70))

$(eval $(call KMOD_template,BT_HCIBCM203X,bt-hcibcm203x,\
	$(MODULES_DIR)/kernel/drivers/bluetooth/bcm203x \
,75))

$(eval $(call KMOD_template,BT_HCIBTUSB,bt-hcibtusb,\
	$(MODULES_DIR)/kernel/drivers/bluetooth/btusb \
,76))

$(eval $(call KMOD_template,BT_HCIUART,bt-hciuart,\
	$(MODULES_DIR)/kernel/drivers/bluetooth/hci_uart \
,75))

$(eval $(call KMOD_template,BT_L2CAP,bt-l2cap,\
	$(MODULES_DIR)/kernel/net/bluetooth/l2cap \
,80))

$(eval $(call KMOD_template,BT_SCO,bt-sco,\
	$(MODULES_DIR)/kernel/net/bluetooth/sco \
,85))

$(eval $(call KMOD_template,BT_BNEP,bt-bnep,\
	$(MODULES_DIR)/kernel/net/bluetooth/bnep/bnep \
,85))

$(eval $(call KMOD_template,BT_RFCOMM,bt-rfcomm,\
	$(MODULES_DIR)/kernel/net/bluetooth/rfcomm/rfcomm \
,85))

#
# Misc devices
#

$(eval $(call KMOD_template,SOFTDOG,softdog,\
	$(MODULES_DIR)/kernel/drivers/char/watchdog/softdog \
,95))

$(eval $(call KMOD_template,FW_LOADER,fw-loader,\
	$(MODULES_DIR)/kernel/drivers/base/firmware_class \
,01))

$(eval $(call KMOD_template,EEPROM_93CX6,eeprom-93cx6,\
	$(MODULES_DIR)/kernel/drivers/misc/eeprom/eeprom_93cx6 \
,05))

$(eval $(call KMOD_template,LEDS_CLASS,leds-class,\
	$(MODULES_DIR)/kernel/drivers/leds/led-class \
,05))

$(eval $(call KMOD_template,LEDS_TRIGGER_TIMER,leds-trigger-timer,\
	$(MODULES_DIR)/kernel/drivers/leds/ledtrig-timer \
,10))

$(eval $(call KMOD_template,LEDS_TRIGGER_HEARTBEAT,leds-trigger-heartbeat,\
	$(MODULES_DIR)/kernel/drivers/leds/ledtrig-heartbeat \
,10))

$(eval $(call KMOD_template,LEDS_TRIGGER_DEFAULT_ON,leds-trigger-default-on,\
	$(MODULES_DIR)/kernel/drivers/leds/ledtrig-default-on \
,10))

$(eval $(call KMOD_template,NETFILTER_XT_TARGET_LED,netfilter-xt-target-led,\
	$(MODULES_DIR)/kernel/net/netfilter/xt_LED \
,90))

#
# NLS
#

$(eval $(call KMOD_template,NLS,nls,\
	$(MODULES_DIR)/kernel/fs/nls/nls_base \
,10))

$(eval $(call KMOD_template,NLS_CODEPAGE_437,nls-codepage-437,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp437 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_737,nls-codepage-737,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp737 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_775,nls-codepage-775,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp775 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_850,nls-codepage-850,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp850 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_852,nls-codepage-852,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp852 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_857,nls-codepage-857,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp857 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_860,nls-codepage-860,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp860 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_861,nls-codepage-861,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp861 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_862,nls-codepage-862,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp862 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_863,nls-codepage-863,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp863 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_864,nls-codepage-864,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp864 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_865,nls-codepage-865,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp865 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_866,nls-codepage-866,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp866 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_869,nls-codepage-869,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp869 \
,20))

NLS_CODEPAGE_874_MODULES := fs/nls/nls_cp874

$(eval $(call KMOD_template,NLS_CODEPAGE_874,nls-codepage-874,\
	$(foreach mod,$(NLS_CODEPAGE_874_MODULES),$(MODULES_DIR)/kernel/$(mod)) \
,20))

NLS_CODEPAGE_932_MODULES := fs/nls/nls_cp932
NLS_CODEPAGE_932_MODULES += fs/nls/nls_euc-jp

$(eval $(call KMOD_template,NLS_CODEPAGE_932,nls-codepage-932,\
	$(foreach mod,$(NLS_CODEPAGE_932_MODULES),$(MODULES_DIR)/kernel/$(mod)) \
,20))

NLS_CODEPAGE_936_MODULES := fs/nls/nls_cp936

$(eval $(call KMOD_template,NLS_CODEPAGE_936,nls-codepage-936,\
	$(foreach mod,$(NLS_CODEPAGE_936_MODULES),$(MODULES_DIR)/kernel/$(mod)) \
,20))

NLS_CODEPAGE_949_MODULES := fs/nls/nls_cp949

$(eval $(call KMOD_template,NLS_CODEPAGE_949,nls-codepage-949,\
	$(foreach mod,$(NLS_CODEPAGE_949_MODULES),$(MODULES_DIR)/kernel/$(mod)) \
,20))

NLS_CODEPAGE_950_MODULES := fs/nls/nls_cp950

$(eval $(call KMOD_template,NLS_CODEPAGE_950,nls-codepage-950,\
	$(foreach mod,$(NLS_CODEPAGE_950_MODULES),$(MODULES_DIR)/kernel/$(mod)) \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_1250,nls-codepage-1250,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp1250 \
,20))

$(eval $(call KMOD_template,NLS_CODEPAGE_1251,nls-codepage-1251,\
	$(MODULES_DIR)/kernel/fs/nls/nls_cp1251 \
,20))

$(eval $(call KMOD_template,NLS_ASCII,nls-ascii, \
	$(MODULES_DIR)/kernel/fs/nls/nls_ascii \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_1,nls-iso8859-1, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-1 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_2,nls-iso8859-2, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-2 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_3,nls-iso8859-3, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-3 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_4,nls-iso8859-4, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-4 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_5,nls-iso8859-5, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-5 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_6,nls-iso8859-6, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-6 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_7,nls-iso8859-7, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-7 \
,20))

NLS_ISO8859_8_MODULES := fs/nls/nls_cp1255

$(eval $(call KMOD_template,NLS_ISO8859_8,nls-iso8859-8, \
	$(foreach mod,$(NLS_ISO8859_8_MODULES),$(MODULES_DIR)/kernel/$(mod)) \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_9,nls-iso8859-9, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-9 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_13,nls-iso8859-13, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-13 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_14,nls-iso8859-14, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-14 \
,20))

$(eval $(call KMOD_template,NLS_ISO8859_15,nls-iso8859-15, \
	$(MODULES_DIR)/kernel/fs/nls/nls_iso8859-15 \
,20))

$(eval $(call KMOD_template,NLS_KOI8_R,nls-koi8-r, \
	$(MODULES_DIR)/kernel/fs/nls/nls_koi8-r \
,20))

$(eval $(call KMOD_template,NLS_KOI8_U,nls-koi8-u, \
	$(MODULES_DIR)/kernel/fs/nls/nls_koi8-u \
	$(MODULES_DIR)/kernel/fs/nls/nls_koi8-ru \
,20))

$(eval $(call KMOD_template,NLS_UTF8,nls-utf8, \
	$(MODULES_DIR)/kernel/fs/nls/nls_utf8 \
,20))

#
# ISDN
#

ISDN_MODULES=drivers/isdn/i4l/isdn

$(eval $(call KMOD_template,ISDN,isdn, \
	$(foreach mod,$(ISDN_MODULES),$(MODULES_DIR)/kernel/$(mod)) \
,60))

$(eval $(call KMOD_template,ISDN_CAPI,isdn-capi, \
	$(MODULES_DIR)/kernel/drivers/isdn/capi/kernelcapi \
	$(MODULES_DIR)/kernel/drivers/isdn/capi/capi \
,60))

$(eval $(call KMOD_template,SLHC,slhc, \
	$(MODULES_DIR)/kernel/drivers/net/slhc \
,65))

$(eval $(call KMOD_template,HISAX,hisax, \
	$(MODULES_DIR)/kernel/drivers/isdn/hisax/hisax \
,70))

MISDN_MODULES=drivers/isdn/hardware/mISDN/mISDN_core
MISDN_MODULES+=drivers/isdn/hardware/mISDN/mISDN_l1
MISDN_MODULES+=drivers/isdn/hardware/mISDN/mISDN_l2
MISDN_MODULES+=drivers/isdn/hardware/mISDN/mISDN_dsp
MISDN_MODULES+=drivers/isdn/hardware/mISDN/mISDN_dtmf
MISDN_MODULES+=drivers/isdn/hardware/mISDN/mISDN_isac
MISDN_MODULES+=drivers/isdn/hardware/mISDN/mISDN_x25dte
MISDN_MODULES+=drivers/isdn/hardware/mISDN/l3udss1

$(eval $(call KMOD_template,MISDN_DRV,misdn-drv, \
	$(foreach mod, $(MISDN_MODULES),$(MODULES_DIR)/kernel/$(mod)) \
,75))

$(eval $(call KMOD_template,MISDN_AVM_FRITZ,misdn-avm-fritz, \
	$(MODULES_DIR)/kernel/drivers/isdn/hardware/mISDN/avmfritz \
,80))

$(eval $(call KMOD_template,MISDN_HFCPCI,misdn-hfcpci, \
	$(MODULES_DIR)/kernel/drivers/isdn/hardware/mISDN/hfcpci \
,80))

$(eval $(call KMOD_template,MISDN_HFCMULTI,misdn-hfcmulti, \
	$(MODULES_DIR)/kernel/drivers/isdn/hardware/mISDN/hfcmulti \
,80))

$(eval $(call KMOD_template,MISDN_HFCMINI,misdn-hfcmini, \
	$(MODULES_DIR)/kernel/drivers/isdn/hardware/mISDN/hfcsmini \
,80))

$(eval $(call KMOD_template,MISDN_XHFC,misdn-xhfc, \
	$(MODULES_DIR)/kernel/drivers/isdn/hardware/mISDN/xhfc \
,80))

$(eval $(call KMOD_template,MISDN_SPEEDFAX,misdn-speedfax, \
	$(MODULES_DIR)/kernel/drivers/isdn/hardware/mISDN/sedlfax \
,80))

#
# Library modules
#

$(eval $(call KMOD_template,CRC_CCITT,crc-ccitt, \
	$(MODULES_DIR)/kernel/lib/crc-ccitt \
,01))

$(eval $(call KMOD_template,CRC_ITU_T,crc-itu-t, \
	$(MODULES_DIR)/kernel/lib/crc-itu-t \
,01))

$(eval $(call KMOD_template,CRC16,crc16, \
	$(MODULES_DIR)/kernel/lib/crc16 \
,01))

$(eval $(call KMOD_template,CRC32,crc32, \
	$(MODULES_DIR)/kernel/lib/crc32 \
,01))

$(eval $(call KMOD_template,LIBCRC32C,libcrc32c, \
	$(MODULES_DIR)/kernel/lib/libcrc32c \
,10))

#
# parallel port support
#

$(eval $(call KMOD_template,LP,lp,\
	$(MODULES_DIR)/kernel/drivers/char/lp \
,60))

$(eval $(call KMOD_template,PPDEV,ppdev,\
	$(MODULES_DIR)/kernel/drivers/char/ppdev \
,60))

$(eval $(call KMOD_template,PARPORT,parport,\
	$(MODULES_DIR)/kernel/drivers/parport/parport \
,50))

$(eval $(call KMOD_template,PLIP,plip,\
	$(MODULES_DIR)/kernel/drivers/net/plip \
,51))

#
# Profiling
#
$(eval $(call KMOD_template,OPROFILE,oprofile,\
	$(MODULES_DIR)/kernel/arch/$(ARCH)/oprofile/oprofile \
,10))

#
# I2C
#
$(eval $(call KMOD_template,I2C,i2c,\
	$(MODULES_DIR)/kernel/drivers/i2c/i2c-core \
	$(MODULES_DIR)/kernel/drivers/i2c/i2c-dev \
,20))

$(eval $(call KMOD_template,SCx200_ACB,scx200-acb,\
	$(MODULES_DIR)/kernel/drivers/i2c/busses/scx200_acb \
,25))

