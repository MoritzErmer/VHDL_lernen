#!/usr/bin/env bash
# Simuliert alle Beispiele in am_rechner/ (Aufruf aus dem Repo-Hauptordner).
set -e
cd "$(dirname "$0")/.."
r=am_rechner
./sim.sh tb_halbaddierer       $r/L01/halbaddierer.vhd  $r/L01/tb_halbaddierer.vhd
./sim.sh tb_volladdierer       $r/L01/volladdierer.vhd  $r/L01/tb_volladdierer.vhd
./sim.sh tb_vektor_spiele      $r/L02/vektor_spiele.vhd $r/L02/tb_vektor_spiele.vhd
./sim.sh tb_rechner_8bit       $r/L02/rechner_8bit.vhd  $r/L02/tb_rechner_8bit.vhd
./sim.sh tb_uebung02           $r/L02/uebung02.vhd      $r/L02/tb_uebung02.vhd
./sim.sh tb_mux4               $r/L03/mux4.vhd          $r/L03/tb_mux4.vhd
./sim.sh tb_siebenseg          $r/L03/siebenseg.vhd     $r/L03/tb_siebenseg.vhd
./sim.sh tb_prio_encoder       $r/L03/prio_encoder.vhd  $r/L03/tb_prio_encoder.vhd
./sim.sh tb_uebung03           $r/L03/uebung03.vhd      $r/L03/tb_uebung03.vhd
./sim.sh tb_signal_vs_variable $r/L04/tb_signal_vs_variable.vhd
./sim.sh tb_alu_4bit           $r/L04/alu_4bit.vhd      $r/L04/tb_alu_4bit.vhd
./sim.sh tb_uebung04           $r/L04/uebung04.vhd      $r/L04/tb_uebung04.vhd
./sim.sh tb_flanke             $r/L05/flanke.vhd        $r/L05/tb_flanke.vhd
./sim.sh tb_detektor           $r/L07/detektor.vhd      $r/L07/tb_detektor.vhd
./sim.sh tb_garagentor         $r/L07/garagentor.vhd    $r/L07/tb_garagentor.vhd
./sim.sh tb_struktur $r/L01/halbaddierer.vhd $r/L08/volladdierer_struct.vhd $r/L05/d_ff.vhd \
         $r/L08/adder_n.vhd $r/L08/schiebereg.vhd $r/L08/priorityencoder.vhd $r/L08/tb_struktur.vhd
./sim.sh tb_block_l $r/L10/gatter.vhd $r/L05/d_ff.vhd $r/L10/kombinatorik.vhd $r/L10/getaktet.vhd \
         $r/L10/modular.vhd $r/L10/tb_block_l.vhd
./sim.sh tb_bausteine          $r/L11/bausteine.vhd $r/L11/tb_bausteine.vhd
./sim.sh tb_klausur            $r/L09/crc.vhd $r/L09/mult.vhd $r/L09/tb_klausur.vhd
./sim.sh tb_projekte           $r/L12/projekte_fsm.vhd $r/L12/projekte_klausur.vhd $r/L12/tb_projekte.vhd
./sim.sh tb_senso              $r/L13/senso.vhd $r/L13/tb_senso.vhd
STOP=1ms ./sim.sh galois_lfsr_tb $r/L13/senso.vhd $r/L13/lfsr_test.vhd
./sim.sh tb_werkstatt          $r/L14/werkstatt.vhd $r/L14/tb_werkstatt.vhd
STOP=1ms ./sim.sh tb_ggt       $r/L14/werkstatt.vhd $r/L14/tb_ggt.vhd
mkdir -p build/extra && ghdl -a --std=08 --workdir=build/extra $r/L01/and_2.vhd $r/L05/d_ff.vhd
echo "Alle Beispiele erfolgreich simuliert."
