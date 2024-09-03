#ifndef IP_C
#define IP_C

#define I_INDEX 17
#define J_INDEX 4

#include "ip.hpp"
#include <fstream>
#include <bitset>
#include <cstring>
#include <systemc.h>
#include <iomanip>
#include <sstream>

// Makro za SystemC proces
SC_HAS_PROCESS(Ip);

// Konstruktor klase Ip
Ip::Ip(sc_module_name name) :
    sc_module(name),
    ready(1),
    iteration_counter(0)  // Inicijalizacija brojača iteracija
{
    SC_THREAD(proc);

    // Inicijalizacija jednosmernog vektora _index sa veličinom _IndexSize * _IndexSize * 4 i početnom vrednošću 0.0f
    _index.resize(_IndexSize * _IndexSize * 4, 0.0f);

    _lookup2.resize(40);
    interconnect_socket.register_b_transport(this, &Ip::b_transport);
    cout << "IP constructed" << endl;
}

// Destruktor klase Ip
Ip::~Ip()
{
    SC_REPORT_INFO("Ip", "Destroyed");
}

// Implementacija b_transport funkcije za TLM
void Ip::b_transport(pl_t& pl, sc_time& offset)
{
    tlm_command cmd = pl.get_command();
    sc_dt::uint64 addr = pl.get_address();
    unsigned char *buf = pl.get_data_ptr();
    unsigned int len = pl.get_data_length();
    pl.set_response_status(TLM_OK_RESPONSE);

    switch (cmd)
    {
        case TLM_WRITE_COMMAND:
            switch(addr)
            {
                case addr_start:
                    start = toInt(buf);
                    cout << "Iteration " << iteration_counter << " - Start value: " << start << endl;
                    proc();
                    break;
                case addr_iradius:
                    iradius = toInt(buf);
                    cout << "Iteration " << iteration_counter << " - iradius: " << iradius << endl;
                    break;    
                case addr_fracr:
                    fracr = toDouble(buf);
                    cout << "Iteration " << iteration_counter << " - fracr: " << fracr << endl;
                    break;
                case addr_fracc:
                    fracc = toDouble(buf);
                    cout << "Iteration " << iteration_counter << " - fracc: " << fracc << endl;
                    break;
                case addr_spacing:
                    inv_spacing = toDouble(buf);
                    cout << "Iteration " << iteration_counter << " - inv_spacing: " << inv_spacing << endl;
                    break;
                case addr_iy:
                    iy = toInt(buf);
                    cout << "Iteration " << iteration_counter << " - iy: " << iy << endl;
                    break;
                case addr_ix:
                    ix = toInt(buf);
                    cout << "Iteration " << iteration_counter << " - ix: " << ix << endl;
                    break;
                case addr_step:
                    step = toInt(buf);
                    cout << "Iteration " << iteration_counter << " - step: " << step << endl;
                    break;
                case addr_cose:
                    _cose = toDouble(buf);
                    cout << "Iteration " << iteration_counter << " - cose: " << _cose << endl;
                    break;
                case addr_sine:
                    _sine = toDouble(buf);
                    cout << "Iteration " << iteration_counter << " - sine: " << _sine << endl;
                    break;
                case addr_scale:
                    scale = toInt(buf);
                    cout << "Iteration " << iteration_counter << " - scale: " << scale << endl;
                    break;
                default:
                    pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
                    cout << "Wrong address" << endl;
            }
            break;
                
        case TLM_READ_COMMAND:
            switch(addr)
            {
                case addr_ready:
                    intToUchar(buf, ready);
                    cout << "Iteration " << iteration_counter << " - Read ready: " << ready << endl;
                    break;
                default:
                    pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
                    cout << "Wrong address" << endl;
            }
            break;
            
        default:
            pl.set_response_status(TLM_COMMAND_ERROR_RESPONSE);
            cout << "Wrong command" << endl;
    }
    offset += sc_time(10, SC_NS);
}

// Implementacija funkcije proc
void Ip::proc() {
    vector<num_f> _lookup2_pom;
    
    for (int n = 0; n < 40; n++) {
        offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
        _lookup2_pom.push_back(read_rom(addr_rom + n));
    }

    std::ofstream lookup2_file("lookup2.txt");
    if (!lookup2_file.is_open()) {
        std::cerr << "Unable to open lookup2 file";
    } else {
        for (const auto& lookup : _lookup2_pom) {
            std::string binary_string = lookup.to_string(SC_BIN);
            binary_string.erase(remove(binary_string.begin(), binary_string.end(), 'b'), binary_string.end());
            binary_string.erase(remove(binary_string.begin(), binary_string.end(), '.'), binary_string.end());
            if (!binary_string.empty()) {
                binary_string.erase(0, 1);
            }
            lookup2_file << binary_string << std::endl;
        }
        lookup2_file.close();
    }

    for (int i = 0; i < 40; i++) {
        _lookup2[i] = static_cast<num_f>(_lookup2_pom[i]);
    } 
    
    vector<num_f> pixels1D;
    for (int w = 0; w < _width; w++) {
        offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
        for (int h = 0; h < _height; h++) {
            offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
            pixels1D.push_back(read_mem(addr_Pixels1 + (w * _height + h)));
        }
    }
    
    std::ofstream pixels1D_file("pixels1D.txt");
    if (!pixels1D_file.is_open()) {
        std::cerr << "Unable to open pixels1D file";
    } else {
        for (const auto& pixel : pixels1D) {
            std::string binary_string = pixel.to_string(SC_BIN);
            binary_string.erase(remove(binary_string.begin(), binary_string.end(), 'b'), binary_string.end());
            binary_string.erase(remove(binary_string.begin(), binary_string.end(), '.'), binary_string.end());
            if (!binary_string.empty()) {
                binary_string.erase(0, 1);
            }
            pixels1D_file << binary_string << std::endl;
        }
        pixels1D_file.close();
    }

    std::ofstream pixels1D_filedec("pixels1Ddec.txt");
    if (!pixels1D_filedec.is_open()) {
        std::cerr << "Unable to open pixels1D file";
    } else {
        for (const auto& pixel : pixels1D) {
            pixels1D_filedec << pixel.to_string(SC_DEC) << ", ";
        }
        pixels1D_filedec.close();
    }
     
    _Pixels = new num_f*[_width];
    for (int i = 0; i < _width; i++) {
        _Pixels[i] = new num_f[_height];
    }
    
    int pixels1D_index2 = 0;
    for (int w = 0; w < _width; w++) {
        for (int h = 0; h < _height; h++) {
            _Pixels[w][h] = static_cast<num_f>(pixels1D[pixels1D_index2++]);
        }
    }  
          
    for (int i = 0; i < _IndexSize; i++) {
        for (int j = 0; j < _IndexSize; j++) {
            for (int k = 0; k < 4; k++)
                _index[i * (_IndexSize * 4) + j * 4 + k] = 0.0;
        }
    }
      
    if (start == 1 && ready == 1) {
        ready = 0;
        offset += sc_time(DELAY, SC_NS);
    } else if (start == 0 && ready == 0) {
       for (int i = 0; i <= 2 * iradius; i++) {
    for (int j = 0; j <= 2 * iradius; j++) {
        num_i ri, ci, ori1, ori2;
        num_f rweight1, rweight2, cweight1, cweight2;
        int index1, index2;
        num_f dxx1, dxx2, dyy1, dyy2;
        num_f dxx, dyy;
        num_f dx1, dx2, dx;
        num_f dy1, dy2, dy;
        num_f rfrac, cfrac;

        // Check for the specific case where i = I_INDEX and j = J_INDEX
        if (i == I_INDEX && j == J_INDEX) {
            cout << "Debug - i: " << i << ", j: " << j << endl;
            cout << "rpos: " << rpos << ", cpos: " << cpos << endl;
            cout << "rx: " << rx << ", cx: " << cx << endl;
            cout << "ri: " << ri << ", ci: " << ci << endl;
            cout << "ori1: " << ori1 << ", ori2: " << ori2 << endl;
            cout << "rweight1: " << rweight1 << ", rweight2: " << rweight2 << endl;
            cout << "cweight1: " << cweight1 << ", cweight2: " << cweight2 << endl;
            cout << "index1: " << index1 << ", index2: " << index2 << endl;
            cout << "Value at _index[index1]: " << _index[index1] << ", Value at _index[index2]: " << _index[index2] << endl;
        }

        rpos = (step * (_cose * (i - iradius) + _sine * (j - iradius)) - fracr) * inv_spacing;
        cpos = (step * (-_sine * (i - iradius) + _cose * (j - iradius)) - fracc) * inv_spacing;
        
        rx = rpos + 2.0 - 0.5;
        cx = cpos + 2.0 - 0.5;

        if (i == I_INDEX && j == J_INDEX) {
            cout << "Calculated rpos: " << rpos << ", cpos: " << cpos << endl;
            cout << "Calculated rx: " << rx << ", cx: " << cx << endl;
        }

        if (rx > -1.0 && rx < (double)_IndexSize && cx > -1.0 && cx < (double)_IndexSize) {
            num_i r = iy + (i - iradius) * step;
            num_i c = ix + (j - iradius) * step;
            num_i addSampleStep = int(scale);

            if (i == I_INDEX && j == J_INDEX) {
                cout << "Calculated r: " << r << ", c: " << c << endl;
                cout << "Calculated addSampleStep: " << addSampleStep << endl;
            }

            if (r >= 1 + addSampleStep && r < _height - 1 - addSampleStep && c >= 1 + addSampleStep && c < _width - 1 - addSampleStep) {
                num_f weight = _lookup2[num_i(rpos * rpos + cpos * cpos)];

                if (i == I_INDEX && j == J_INDEX) {
                    cout << "Calculated weight: " << weight << endl;
                }

                dxx1 = pixels1D[(r + addSampleStep + 1) * _width + (c + addSampleStep + 1)] 
                     + pixels1D[(r - addSampleStep) * _width + c]
                     - pixels1D[(r - addSampleStep) * _width + (c + addSampleStep + 1)]
                     - pixels1D[(r + addSampleStep + 1) * _width + c];
                dxx2 = pixels1D[(r + addSampleStep + 1) * _width + (c + 1)]
                     + pixels1D[(r - addSampleStep) * _width + (c - addSampleStep)]
                     - pixels1D[(r - addSampleStep) * _width + (c + 1)]
                     - pixels1D[(r + addSampleStep + 1) * _width + (c - addSampleStep)];

                dyy1 = pixels1D[(r + 1) * _width + (c + addSampleStep + 1)]
                     + pixels1D[(r - addSampleStep) * _width + (c - addSampleStep)]
                     - pixels1D[(r - addSampleStep) * _width + (c + addSampleStep + 1)]
                     - pixels1D[(r + 1) * _width + (c - addSampleStep)];
                dyy2 = pixels1D[(r + addSampleStep + 1) * _width + (c + addSampleStep + 1)]
                     + pixels1D[r * _width + (c - addSampleStep)]
                     - pixels1D[r * _width + (c + addSampleStep + 1)]
                     - pixels1D[(r + addSampleStep + 1) * _width + (c - addSampleStep)];

                if (i == I_INDEX && j == J_INDEX) {
                    cout << "Calculated dxx1: " << dxx1 << ", dxx2: " << dxx2 << endl;
                    cout << "Calculated dyy1: " << dyy1 << ", dyy2: " << dyy2 << endl;
                }

                dxx = weight * (dxx1 - dxx2);
                dyy = weight * (dyy1 - dyy2);

                if (i == I_INDEX && j == J_INDEX) {
                    cout << "Calculated dxx: " << dxx << ", dyy: " << dyy << endl;
                }

                dx1 = _cose * dxx;
                dx2 = _sine * dyy;
                dx = dx1 + dx2;

                dy1 = _sine * dxx;
                dy2 = _cose * dyy;
                dy = dy1 - dy2;

                if (i == I_INDEX && j == J_INDEX) {
                    cout << "Calculated dx1: " << dx1 << ", dx2: " << dx2 << ", dx: " << dx << endl;
                    cout << "Calculated dy1: " << dy1 << ", dy2: " << dy2 << ", dy: " << dy << endl;
                }

                if (dx < 0) ori1 = 0;
                else ori1 = 1;

                if (dy < 0) ori2 = 2;
                else ori2 = 3;

                if (i == I_INDEX && j == J_INDEX) {
                    cout << "Determined ori1: " << ori1 << ", ori2: " << ori2 << endl;
                }

                if (rx < 0) ri = 0;
                else if (rx >= _IndexSize) ri = _IndexSize - 1;
                else ri = rx;

                if (cx < 0) ci = 0;
                else if (cx >= _IndexSize) ci = _IndexSize - 1;
                else ci = cx;

                if (i == I_INDEX && j == J_INDEX) {
                    cout << "Determined ri: " << ri << ", ci: " << ci << endl;
                }

                rfrac = rx - ri;
                cfrac = cx - ci;

                if (rfrac < 0.0) rfrac = 0.0;
                else if (rfrac > 1.0) rfrac = 1.0;
                
                if (cfrac < 0.0) cfrac = 0.0;
                else if (cfrac > 1.0) cfrac = 1.0;

                if (i == I_INDEX && j == J_INDEX) {
                    cout << "Calculated rfrac: " << rfrac << ", cfrac: " << cfrac << endl;
                }

                rweight1 = dx * (1.0 - rfrac);
                rweight2 = dy * (1.0 - rfrac);
                cweight1 = rweight1 * (1.0 - cfrac);
                cweight2 = rweight2 * (1.0 - cfrac);

                if (i == I_INDEX && j == J_INDEX) {
                    cout << "Calculated rweight1: " << rweight1 << ", rweight2: " << rweight2 << endl;
                    cout << "Calculated cweight1: " << cweight1 << ", cweight2: " << cweight2 << endl;
                }

                if (ri >= 0 && ri < _IndexSize && ci >= 0 && ci < _IndexSize) {
                    _index[ri * (_IndexSize * 4) + ci * 4 + ori1] = cweight1;
                    _index[ri * (_IndexSize * 4) + ci * 4 + ori2] = cweight2;

                    cout << "Updated _index[" << ri * (_IndexSize * 4) + ci * 4 + ori1 << "] = " << cweight1 << endl;
                    cout << "Updated _index[" << ri * (_IndexSize * 4) + ci * 4 + ori2 << "] = " << cweight2 << endl;
                }
            }  
        }
    }
}


        mem.clear();

        num_f* index1D = new num_f[_IndexSize * _IndexSize * 4];
        
        int index1D_index = 0;
        for (int i = 0; i < _IndexSize; i++) {
            for (int j = 0; j < _IndexSize; j++) {
                for (int k = 0; k < 4; k++) {
                    index1D[index1D_index++] = static_cast<num_f>(_index[i * (_IndexSize * 4) + j * 4 + k]);
                }
            }
        }

        for (long unsigned int i = 0; i < _IndexSize * _IndexSize * 4; ++i) {
            mem.push_back(index1D[i]);
        }

        std::string filename1 = "index1Dbin.txt";

        std::ofstream outfile1(filename1, std::ios::binary | std::ios::app);
        if (!outfile1.is_open()) {
            std::cerr << "Unable to open file";
        } else {
            outfile1 << "# Iteration " << iteration_counter << std::endl;
            for (size_t i = 0; i < _IndexSize * _IndexSize * 4; i++) {
                std::string binary_string = index1D[i].to_string(SC_BIN);
                size_t prefix_position = binary_string.find("0b");
                if (prefix_position != std::string::npos) {
                    binary_string.erase(prefix_position, 2);
                }
                binary_string.erase(std::remove(binary_string.begin(), binary_string.end(), '.'), binary_string.end());
                outfile1 << binary_string << std::endl;
            }
            outfile1.close();
        }

        std::string filename2 = "index1Ddec.txt";

        std::ofstream outfile2(filename2, std::ios::binary | std::ios::app);
        if (!outfile2.is_open()) {
            std::cerr << "Unable to open file";
        } else {
            outfile2 << "# Iteration " << iteration_counter << std::endl;
            for (size_t i = 0; i < _IndexSize * _IndexSize * 4; i++) {
                outfile2 << index1D[i].to_string(SC_DEC) << std::endl;
            }
            outfile2.close();
        }

        iteration_counter++;

        for (int i = 0; i < _IndexSize * _IndexSize * 4; i++) {
            pl_t pl;
            offset += sc_core::sc_time(DELAY, sc_core::SC_NS);
            unsigned char* buf;
            buf = (unsigned char*)&mem[i];
            pl.set_address(addr_index1 + i);
            pl.set_data_length(1);
            pl.set_data_ptr(buf);
            pl.set_command(tlm::TLM_WRITE_COMMAND);
            pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
            mem_socket->b_transport(pl, offset);
        }

        for (int i = 0; i < _width; i++) {
            delete[] _Pixels[i];
        }
        delete[] _Pixels; 

        cout << "Entry from IP to memory completed" << endl;
        ready = 1;
    }
}

void Ip::write_mem(sc_uint<64> addr, num_f val) 
{
    pl_t pl;
    unsigned char buf[6];
    doubleToUchar(buf, val);
    pl.set_address(addr);
    pl.set_data_length(1);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_WRITE_COMMAND);
    pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
    mem_socket->b_transport(pl, offset);
}

num_f Ip::read_rom(sc_dt::sc_uint<64> addr)
{
    pl_t pl;
    unsigned char buf[6];
    pl.set_address(addr);
    pl.set_data_length(6);
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
    rom_socket->b_transport(pl, offset);
    
    return toNum_f(buf);
}

num_f Ip::read_mem(sc_dt::sc_uint<64> addr)
{
    pl_t pl;
    unsigned char buf[6];
    pl.set_address(addr);
    pl.set_data_length(6); 
    pl.set_data_ptr(buf);
    pl.set_command(tlm::TLM_READ_COMMAND);
    pl.set_response_status(TLM_INCOMPLETE_RESPONSE);
    mem_socket->b_transport(pl, offset);
    
    return toNum_f(buf);
}

#endif // IP_C

