#include <eosiolib/eosio.hpp>
using namespace eosio;

class [[eosio::contract]] scamdatalist : public eosio::contract {
	public:
		using contract::contract;
		scamdatalist (name receiver, name code,  datastream<const char*> ds): contract(receiver, code, ds) {}

		//uint64_t idNo = 1;

		[[eosio::action]]
		 void addscam(std::string address, std::string text){
			require_auth(_self);
			scamlists _scamlists(_code,_code.value);



			_scamlists.emplace(_self, [&](auto& row){
				row.id=_scamlists.available_primary_key();
				row.address = address;
				row.text = text;
			});

		}

		[[eosio::action]]
		 void addwhite(std::string address, std::string text){
			require_auth(_self);
			whitelists _whitelists(_code,_code.value);



			_whitelists.emplace(_self, [&](auto& row){
				row.id=_whitelists.available_primary_key();
				row.address = address;
				row.text = text;
			});

		}

		[[eosio::action]]
		void delall()
		{
			require_auth(_self);
			scamlists _scamlists(_code,_code.value);

			auto iter = _scamlists.begin();
			while(iter != _scamlists.end()){
					iter = _scamlists.erase(iter);
			}
		}


		struct [[eosio::table]] scam {
			uint64_t id;
			std::string address;
			std::string text;
			uint64_t primary_key()const { return id; }
		};
		struct [[eosio::table]] white {
			uint64_t id;
			std::string address;
			std::string text;
			uint64_t primary_key()const { return id; }
		};
		typedef eosio::multi_index<name("scamlist"),scam> scamlists;
		typedef eosio::multi_index<name("whitelist"),white> whitelists;

};


EOSIO_DISPATCH( scamdatalist, (addscam)(addwhite)(delall))