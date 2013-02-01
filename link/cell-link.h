#ifndef CELL_LINK_HH
#define CELL_LINK_HH

#include<vector>
#include "rng.h"
#include "cdma-rates.h"
#include "delay.h"

/* An implementation of a multiuser Cellular Link.
 * Each user has independent Poisson services.
 */

class CellLink : public LinkDelay {
  private:
    uint32_t _num_users;
    std::vector<double> _current_rates;
    std::vector<double> _average_rates;
    std::vector<RNG*>    _rate_generators;
    uint32_t _iter;

  public :
    /* Constructor */
    CellLink();

    /* Called by CellLink inside the body of recv() */
    void tick( void );

    /* Generate new rates from allowed rates */
    void generate_new_rates();

    /* Get current rates of all users for SFD::deque() to use.
       SFD could ignore this as well. */
    std::vector<double> get_current_rates();

    /* override the recv function from LinkDelay */
    virtual void recv( Packet* p, Handler* h);

};

#endif