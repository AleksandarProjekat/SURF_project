#ifndef IP_H
#define IP_H
#define SC_INCLUDE_FX

#include <iostream>
#include <systemc>
#include <string>
#include <fstream>
#include <deque>
#include <vector>
#include <array>
#include <algorithm>
#include "utils.hpp"
#include "types.hpp"
#include "addr.hpp"
#include "tlm_utils/tlm_quantumkeeper.h"

using namespace std;
using namespace sc_core;

SC_MODULE(Ip)
{   
    public:
        Ip(sc_module_name name);  // Konstruktor
        ~Ip();  // Destruktor

        // TLM soketi
        tlm_utils::simple_target_socket<Ip> interconnect_socket;
        tlm_utils::simple_initiator_socket<Ip> mem_socket;
        tlm_utils::simple_initiator_socket<Ip> rom_socket;

    protected:
        void b_transport(pl_t&, sc_time&);  // TLM funkcija za prenos podataka
        void proc();  // Glavni proces

        // Funkcije za čitanje i pisanje memorije
        void write_mem(sc_uint<64> addr, num_f val);
        num_f read_mem(sc_uint<64> addr);
        num_f read_rom(sc_uint<64> addr);

        // Interni podaci
        vector<num_f> mem;  // Interna memorija
        sc_core::sc_time offset;  // Vremenski ofset

        // Različite promenljive za kontrolu i stanje
        sc_uint<1> ready;
        sc_uint<1> start;
        int iteration_counter;

        // Razni vektori i promenljive korišćene u obradi
        std::vector<num_f> pixels1D;
        std::vector<num_f> _lookup2;     
        num_i iradius;
        num_f fracr;
        num_f fracc;
        num_f inv_spacing;
        num_f rpos;
        num_f cpos;
        num_i step;
        num_f _cose;
        num_f _sine;
        num_i iy;
        num_i ix;
        num_f rx;
        num_f cx;
        num_i scale;
        num_f** _Pixels;

        // Promena sa trodimenzionalnog vektora na jednosmerni vektor
        std::vector<num_f> _index;  // Jednosmerni vektor za indeksiranje
};

#endif // IP_H

