-- Primer insereix els tenants
INSERT INTO tenants (name, subdomain, plan_type, api_key, is_active)
VALUES
  ('Acme Mobility', 'acme', 'standard', 'ACME_KEY_123', 1),
  ('Beta Transport', 'beta', 'premium', 'BETA_KEY_456', 1);

-- Super Admin (tenant_admin role - platform-wide access)
-- Password: admin123
-- Nota: tenant_id = 0 indica que és un super admin sense tenant assignat
INSERT INTO users (tenant_id, email, password_hash, role, name, is_active)
VALUES
  (0, 'admin@ecomotion.com', '$2y$10$zR9VASoHNA2aKxbL2hTLlO0n2Jz0OLevkjdOj0c1ILMUHtyw7B6LS', 'tenant_admin', 'Platform Admin', 1);

-- Managers
-- Password: manager123
INSERT INTO users (tenant_id, email, password_hash, role, name, is_active)
VALUES
  (1, 'manager@acme.test', '$2y$10$TGaQLPp//0VJtaBYC1B0peUDAn4hyyMefuLeBsD0.TPnti2JZzbQW', 'manager', 'Acme Manager', 1),
  (2, 'manager@beta.test', '$2y$10$TGaQLPp//0VJtaBYC1B0peUDAn4hyyMefuLeBsD0.TPnti2JZzbQW', 'manager', 'Beta Manager', 1);

-- Clients
-- Password: client123
INSERT INTO users (tenant_id, email, password_hash, role, name, is_active)
VALUES
  (1, 'client1@acme.test', '$2y$10$VPwbAvRRfXq9rutFqiSPFe6E0VQbrdUC.vrdepkkNaOG3LnsFMXO2', 'client', 'Acme Client 1', 1),
  (2, 'client1@beta.test', '$2y$10$VPwbAvRRfXq9rutFqiSPFe6E0VQbrdUC.vrdepkkNaOG3LnsFMXO2', 'client', 'Beta Client 1', 1);

-- Vehicles (sintaxi MySQL/MariaDB per tipus POINT)
INSERT INTO vehicles (tenant_id, vin, model, battery_capacity, status, location, sensor_data)
VALUES
  (1, 'ACMEVIN000000001', 'E-Scooter A1', 1.2, 'available', ST_GeomFromText('POINT(-3.7038 40.4168)'), '{"battery":85}'),
  (1, 'ACMEVIN000000002', 'E-Bike B2', 0.8, 'maintenance', ST_GeomFromText('POINT(-3.69 40.42)'), '{"battery":60}'),
  (2, 'BETAVIN000000001', 'E-Scooter Z1', 1.1, 'booked', ST_GeomFromText('POINT(2.1734 41.3851)'), '{"battery":45}'),
  (2, 'BETAVIN000000002', 'E-Car C3', 40.0, 'charging', ST_GeomFromText('POINT(2.18 41.39)'), '{"battery":72}');
