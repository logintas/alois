# Copyright 2010 The Apache Software Foundation.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class CreateUlogdNfctMetas < ActiveRecord::Migration
  def self.up
      create_table :ulogd_nfct_metas do |t|
        # ulogd filter "PRINTFLOW"
        # Input keys:
        #         Key: orig.ip.saddr.str (IP addr)
        #         Key: orig.ip.daddr.str (IP addr)
        #         Key: orig.ip.protocol (unsigned int 8)
        #         Key: orig.l4.sport (unsigned int 16)
        #         Key: orig.l4.dport (unsigned int 16)
        #         Key: orig.raw.pktlen (unsigned int 32)
        #         Key: orig.raw.pktcount (unsigned int 32)
        #         Key: reply.ip.saddr.str (IP addr)
        #         Key: reply.ip.daddr.str (IP addr)
        #         Key: reply.ip.protocol (unsigned int 8)
        #         Key: reply.l4.sport (unsigned int 16)
        #         Key: reply.l4.dport (unsigned int 16)
        #         Key: reply.raw.pktlen (unsigned int 32)
        #         Key: reply.raw.pktcount (unsigned int 32)
        #         Key: icmp.code (unsigned int 8)
        #         Key: icmp.type (unsigned int 8)
        #         Key: ct.event (unsigned int 32)
        t.column :process_id, :integer
        t.column :event, :string, :limit => 16
        t.column :orig_saddr, :string, :limit => 50
        t.column :orig_daddr, :string, :limit => 50
        t.column :orig_protocol, :string, :limit => 10
        t.column :orig_sport, :int
        t.column :orig_dport, :int
        t.column :orig_pktlen, :int
        t.column :orig_pktcount, :int
        t.column :reply_saddr, :string, :limit => 50
        t.column :reply_daddr, :string, :limit => 50
        t.column :reply_protocol, :string, :limit => 10
        t.column :reply_sport, :int
        t.column :reply_dport, :int
        t.column :reply_pktlen, :int
        t.column :reply_pktcount, :int
        t.column :icmp_code, :int
        t.column :icmp_type, :int
        t.column :log_metas_id, :integer
        t.column :pure_metas_id, :integer
      end

    add_index :ulogd_nfct_metas, :event
    add_index :ulogd_nfct_metas, :orig_saddr
    add_index :ulogd_nfct_metas, :orig_daddr
    add_index :ulogd_nfct_metas, :orig_protocol
    add_index :ulogd_nfct_metas, :orig_sport
    add_index :ulogd_nfct_metas, :orig_dport
    add_index :ulogd_nfct_metas, :orig_pktcount
    add_index :ulogd_nfct_metas, :reply_saddr
    add_index :ulogd_nfct_metas, :reply_daddr
    add_index :ulogd_nfct_metas, :reply_protocol
    add_index :ulogd_nfct_metas, :reply_sport
    add_index :ulogd_nfct_metas, :reply_dport
    add_index :ulogd_nfct_metas, :reply_pktlen
    add_index :ulogd_nfct_metas, :reply_pktcount
    add_index :ulogd_nfct_metas, :icmp_code
    add_index :ulogd_nfct_metas, :icmp_type
    add_index :ulogd_nfct_metas, :log_metas_id
  end

  def self.down
    drop_table :ulogd_nfct_metas
  end
end
